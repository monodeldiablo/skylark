/* main.vala
 *
 * Copyright (C) 2010  Brian Davis
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author:
 * 	Brian Davis <brian.william.davis@gmail.com>
 */

using GLib;
using Soup;
using Config;

public class Skylark.Proxy: Object
{
	private Soup.Server server;
	private Skylark.Filter[] filter_chain;
	private GLib.MainLoop mainloop;

	public Proxy (int port = 58008)
	{
		this.mainloop = new GLib.MainLoop (null, false);
		this.server = new Soup.Server (Soup.SERVER_PORT, port);

		// Set the default handler to take any request.
		this.server.add_handler ("", this.handle_request);

		this.filter_chain = {};
		this.load_filters ();
	}

	public void run ()
	{
		this.server.run ();
	}

	private void load_filters ()
	{
		var filter_directory = GLib.File.new_for_path (Config.PACKAGE_DATADIR);
		var iter = filter_directory.enumerate_children ("*", GLib.FileQueryInfoFlags.NONE);
		var info = iter.next_file ();

		// NOTE: This doesn't check content type, so don't put anything silly in the
		//       filter directory.
		while (info != null)
		{
			var file = GLib.Path.build_filename (Config.PACKAGE_DATADIR, info.get_name ());
			var filter = new Skylark.Filter (file);

			this.filter_chain += filter;
			info = iter.next_file ();
		}

		iter.close ();
	}

	private void handle_request (Soup.Server server,
		Soup.Message message,
		string path,
		GLib.HashTable? query,
		Soup.ClientContext client)
	{
		var now = GLib.TimeVal ();
		var uri = message.uri.to_string (false);

		// Log each access.
		log (null,
			GLib.LogLevelFlags.LEVEL_INFO,
			"[%s] %s %s %s",
			now.to_iso8601 (),
			client.get_host (),
			message.method,
			uri);

		// Fetch the requested resource.
		var session = new Soup.SessionSync ();
		var remote_request = new Soup.Message (message.method, uri);

		session.user_agent = "Skylark 0.1";

		// If we need authentication, prompt.
		session.authenticate.connect ((sess, msg, auth, retrying) =>
		{
			if (!retrying)
			{
				log (null,
					GLib.LogLevelFlags.LEVEL_INFO,
					"[%s] Authentication Required",
					now.to_iso8601 ());
				auth.authenticate ("user", "password");
			}
		});

		// This protects against Google's heartbeat, which uses an empty message.
		// FIXME: This means that Google apps are screwed...
		if (remote_request != null)
		{
			// Stick the contents into remote_request's response_body attribute.
			session.send_message (remote_request);

			var content_type = remote_request.response_headers.get_content_type (null);
			string body = remote_request.response_body.flatten ().data;

			// FIXME: This is temporary, until images are fixed below. Apparently, by
			//        casting the data as a string (see above), images are corrupted.
			if (content_type.contains ("image"))
			{
				message.set_response (content_type,
					Soup.MemoryUse.COPY,
					remote_request.response_body.flatten ().data,
					(size_t) remote_request.response_body.length);
			}

			else
			{
				// Feed the requested URI through the filter chain.
				foreach (Filter f in this.filter_chain)
				{
					body = f.process (uri, body);
				}

				// Return the (potentially altered) resource to the client.
				message.set_response (content_type,
					Soup.MemoryUse.COPY,
					body,
					body.length);
			}

			message.set_status (Soup.KnownStatusCode.OK);
		}
	}

	static int main (string[] args) {
		var proxy = new Proxy ();
		proxy.run ();
		return 0;
	}
}

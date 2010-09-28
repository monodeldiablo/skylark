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

public class Skylark.Proxy: Object
{
	private Soup.Server server;

	public Proxy (int port = 58008)
	{
		this.server = new Soup.Server (Soup.SERVER_PORT, port);

		// Set the default handler to take any request.
		this.server.add_handler ("", this.handle_request);
	}

	public void run ()
	{
		this.server.run ();
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
			// FIXME: Feed the requested URI through a series of Regexen (filter chain).
			// FIXME: Break these out into modular filter chains.
			try
			{
				// Replace all of Erin's fonts with Comic Sans.
				// FIXME: Make this a more bullet-proof regex.
				if (uri.contains ("erinkendig.com/style/css/portfolio-layout.css"))
				{
					debug ("messing with fonts");
					body = body.replace ("'Droid Sans', arial, sans-serif", "Comic Sans MS, Comic Sans, Marker Felt");
				}

				if (uri == "http://www.erinkendig.com/")
				{
					debug ("messing with images");
					body = body.replace ("style/images/content/siddhartha/sid-spine.jpg",
						"http://unpac.org/sid-spine.jpg");
				}
			}

			catch (GLib.RegexError e)
			{
				stderr.printf (e.message);
			}

			// Return the (potentially altered) resource to the client.
			// FIXME: This seems broken for images.
			message.set_response (content_type,
				Soup.MemoryUse.COPY,
				body,
				body.length);
		}

		message.set_status (Soup.KnownStatusCode.OK);
	}

	static int main (string[] args) {
		var proxy = new Proxy ();
		proxy.run ();
		return 0;
	}
}

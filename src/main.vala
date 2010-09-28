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
		// FIXME: Fetch the requested resource.
		// FIXME: Feed the requested URI through a series of Regexen (filter chain).
		// FIXME: For any match, perform an operation on the contents, returning the new contents.
		// FIXME: Return the (potentially altered) resource to the client.

		var response_text = message.uri.to_string (false);

		message.set_response ("text/html",
			Soup.MemoryUse.COPY,
			response_text,
			response_text.size ());
		message.set_status (Soup.KnownStatusCode.OK);
	}

	static int main (string[] args) {
		var proxy = new Proxy ();
		proxy.run ();
		return 0;
	}
}

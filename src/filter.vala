/* filter.vala
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
using Json;

public class Skylark.Filter : GLib.Object
{
	string name;
	GLib.Regex url;
	GLib.Regex capture;
	string replace;

	public Filter (string path) throws GLib.Error
	{
		var parser = new Json.Parser ();
		parser.load_from_file (path);
		var root = parser.get_root ().get_object ();

		this.name = root.get_string_member ("name");
		this.replace = root.get_string_member ("replace");
		this.url = new Regex (root.get_string_member ("url"));
		this.capture = new Regex (root.get_string_member ("capture"));

		log (null,
			GLib.LogLevelFlags.LEVEL_INFO,
			"Successfully loaded '%s'",
			this.name);
	}

	public string process (string uri, string body)
	{
		var new_body = body;

		if (this.url.match (uri))
		{
			log (null,
				GLib.LogLevelFlags.LEVEL_INFO,
				"Processing '%s'...",
				this.name);

			try
			{
				new_body = this.capture.replace (body, body.length, 0, this.replace);
			}

			catch (GLib.RegexError e)
			{
				critical ("Could not process '%s': %s", this.name, e.message);
			}
		}

		return new_body;
	}
}

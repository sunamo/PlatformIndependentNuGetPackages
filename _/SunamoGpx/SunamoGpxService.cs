namespace SunamoGpx;
using SharpGPX;
using SharpGPX.GPX1_1;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

public class SunamoGpxService
{
    public static string GenerateGpxFile(string creator, List<Item?> list)
    {
        GpxClass gpx = new()
        {
            Creator = creator
        };

        foreach (var item in list)
        {
            if (item == null)
            {
                continue;
            }

            wptType waypoint = new()
            {
                lat = (decimal)item.Position.lat,
                lon = (decimal)item.Position.lon,
                name = item.Name
            };
            gpx.AddWaypoint(waypoint);
        }

        return gpx.ToXml(GpxVersion.GPX_1_1).Replace("utf-16", "utf-8");
    }
}
package funkbucks;

import funkin.util.FileUtil;
import funkin.util.FileWriteMode;
using StringTools;

/**
 * i'm tired of zipping this mod manually
 */
class ZipUtil
{
    final EXCLUDED_FILES:Array<String> =
    [
        '.gitattributes',
        '.gitignore',
        'astc-data.json',
        'scripts/ZipUtil.hx',
        'scripts/TimedCoinsManager.hx',
        'scripts/objects/CloverCoin.hx',
        'scripts/objects/ui/TimedCoinsHUD.hx',
        'scripts/objects/ui/TimedCoinsNote.hx',
        'data/pointlesspins/awards.json'
    ];

    final EXCLUDED_FOLDERS:Array<String> =
    [
        '.git',
        'astc-images/',
        'fla/',
        'fla-public/',
        'music/',
        'old/',
        'unused/',
        'shared/',
        'export/',
        'scripts/awards/',
        'scripts/characters/'
    ];

    final EXCLUDED_FILE_EXT:Array<String> =
    [
        '.zip'
    ];

    final PATH:String = 'mods/PointlessPins/';

    var ASTC_EXCLUDES:Array<String> = [];
    var exportToMobile:Bool = false;
    var zipEntries:Array<Entry> = [];

    public function new(mobile:Bool = false):Void
    {
        exportToMobile = mobile;

        ASTC_EXCLUDES = FileUtil.readJSONFromPath('$PATH/astc-data.json').excludes;
    }

    /**
     * Packages the mod into a zip file. Mobile version images will adhere by the `astc-data.json` exclusion list.
     * Certain paths and files are ignored, since they're not required for the mod to function/shouldn't be public. (such as the whole fla folder :skull:)
     */
    public function packageMod():Void
    {
        final exportPath:String = '$PATH/export/pointlesspins-${FunkBucks.modVersion.replace('.', '_')}${(exportToMobile ? '-mobile' : '')}.zip';
        makeEntries(PATH);
        FileUtil.saveFilesAsZIPToPath(zipEntries, exportPath, FileWriteMode.Force);
    }

    /**
     * Recursively create zip entries for all valid files.
     */
    function makeEntries(path:String):Void
    {
        final pathItems:Array<String> = readDirectory(path);
        for (item in pathItems)
        {
            if (!FileUtil.directoryExists(path + item))
            {
                var pathToUse:String = path;
                var itemToUse:String = item;

                if (exportToMobile && pathToUse.contains('images/') && itemToUse.endsWith('.png') && !containsAny(pathToUse.replace(PATH, '') + itemToUse, ASTC_EXCLUDES, true))
                {
                    pathToUse = pathToUse.replace('images/', 'astc-images/images/');
                    itemToUse = itemToUse.replace('.png', '.astc');
                }

                var bytes:Bytes = FileUtil.readBytesFromPath(pathToUse + itemToUse);
                pathToUse.replace('astc-images/', '');
                zipEntries.push(FileUtil.makeZIPEntryFromBytes(path.replace(PATH, '') + itemToUse, bytes));
            }
            else
            {
                makeEntries(path + item + '/');
            }
        }
    }

    /**
     * Reads a directory and automatically filters out excluded files and such.
     */
    function readDirectory(path:String):Array<String>
    {
        var entries:Array<String> = FileUtil.readDir(path);
        return entries.filter(function(entry:String):Bool
        {
            return !containsAny(path + entry, EXCLUDED_FILES) && !containsAny(path + entry, EXCLUDED_FOLDERS) && !containsAny(entry, EXCLUDED_FILE_EXT);
        });
    }

    /**
     * Check to see if a path contains any of the elements of a given array.
     */
    function containsAny(path:String, elements:Array<String>, astc:Bool = false):Bool
    {
        // Early return if we're checking for astc exclusions and there are none.
        if (astc && (ASTC_EXCLUDES == null || ASTC_EXCLUDES.length == 0)) return false;

        var containsElement:Bool = false;
        for (element in elements)
        {
            if (path.contains(element))
            {
                containsElement = true;
                break;
            }
        }
        return containsElement;
    }
}
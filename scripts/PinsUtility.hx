package funkbucks;

class PinUtil
{
	public static function wrapAround(target:Int, min:Int, max:Int):Int
    {
        if (target < min) {
            return max;
        } else if (target > max) {
            return min;
        } else {
            return target;
        }
    }
}
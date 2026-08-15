package funkbucks;

class PinUtil
{
	/**
	 * Wrap a number around if it goes below the minimum or above the maximum. Useful for looping menu navigation.
	 * @param target The value to wrap.
	 * @param min How low `target` can be.
	 * @param max How high `target` can be.
	 * @return If `target` was above `max`, the return is `min`, and vice-versa.
	 */
	public static function wrapAround(target:Int, min:Int, max:Int):Int
    {
        if (target < min)
        {
            return max;
        }
        else if (target > max)
        {
            return min;
        }
        else
        {
            return target;
        }
    }

    /**
     * Wrap a number around if it goes below the minimum or above the maximum. Useful for looping menu navigation with larger steps than 1/-1.
     * 
     * Unlike `wrapAround()` this one takes the current value and the change separately.
     * 
     * If `current + change` goes above `max`, the step from `max` to `min` counts as 1. Same for the other way.
     * 
     * With `wrapAroundAndContinue(2, -5, 0, 10)` the result will be 8 `(1 -> 0 -> 10 -> 9 -> 8)`, instead of 7 like you'd probably think.
     * 
     * @param current The current value to change.
     * @param change How much to change `current` by.
     * @param min How low `current` can be.
     * @param max How high `current` can be.
     * @return The wrapped value.
     */
    public static function wrapAroundAndContinue(current:Int, change:Int, min:Int, max:Int):Int
    {
        if (current + change < min)
        {
            final diff:Int = min + current;
            return max + (change + diff) + 1;
        }
        else if (current + change > max)
        {
            final diff:Int = max - current;
            return min + (change - diff) - 1;
        }
        else
        {
            return current + change;
        }
    }
}
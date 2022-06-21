/**
 * Created by Matthew on 2019-06-24.
 */

public class StringUtil {

	/*
		This class returns an empty string if target is null, otherwise returns target.
	 */
	public static String NullSafe(String target) {
		if(target == null) return '';
		return target;
	}

}
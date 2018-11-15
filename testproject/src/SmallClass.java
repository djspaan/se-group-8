/*
 * This is an example comment.
 */
public class SmallClass {
	int var1;
	
	SmallClass() {
		var1 = 1;
		/* "string in comment"; */
		String s = "/* comment in string */";
		char c = '\"';
	}
	
	int getVar1() {
		// increment var1 by 1 and return
		int res = var1 + 1;
		int res2 = var1 + 2;
		int res3 = var1 + 3;
		
		// additional useless calculations
		int res4 = res2 + res3;

		int res5 = res4 + 1;
		
		if	(res4 > res5) {
			return 1;
		}

		return res;
	}
	
	/*
	 
	int thisIsAComment(){
		int res = var1 + 1;
		int res2 = var1 + 2;
		int res3 = var1 + 3;
		
		// additional useless calculations
		int res4 = res2 + res3;

		int res5 = res4 + 1;
		
		if	(res4 > res5) {
			return 1;
		}

		return res;
	  
	}
	 
	*/
	
	int getVar2() {
		// increment var1 by 1 and return
		int res = var1 + 1;
		int res2 = var1 + 2;
		int res3 = var1 + 3;
		
		// additional useless calculations
		int res4 = res2 + res3;
		int res5 = res4 + 1;
		
		if	(res4 > res5) {
			return 1;
		}
		
		return res;
	}
}
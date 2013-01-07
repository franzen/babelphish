
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import org.junit.*;

public class JavaTest {

	@Test
	public void testSignedInt() throws IOException {
        System.out.println("Test Signed Int32");
		SignedInt ser = buildObj();
		
		serialize(ser);
		byte[] res = deserialize();

		SignedInt deser = new SignedInt();
		deser.deserialize(new ByteArrayInputStream(res));

		compare(ser, deser);
	}

	public SignedInt buildObj() {
		SignedInt obj = new SignedInt();
		obj.list1   = new ArrayList<Integer>(){{
			add(-1);
			add(-2);
			add(-3);
			add(Integer.MAX_VALUE);
			add(Integer.MIN_VALUE);
		}};
		
		obj.list2   = new ArrayList<Long>(){{
			add(-1L);
			add(-2L);
			add(-3L);
			add( (long)Math.pow(2, 54-1)-1 );
			add( (long)(Math.pow(2, (54-1)) - Math.pow(2, 54)) );
     			//add(Long.MAX_VALUE);
			//add(Long.MIN_VALUE);
		}};

		return obj;
	}

	public void compare(SignedInt obj1, SignedInt obj2) {
		for (int i = 0; i < obj1.list2.size(); i++){
	        //System.out.println("Ser = " + obj1.list2.get(i) + ", Deser = " + obj2.list2.get(i));
			org.junit.Assert.assertEquals(obj1.list2.get(i), obj2.list2.get(i));
		}
		for (int i = 0; i < obj1.list1.size(); i++){
	        //System.out.println("Ser = " + obj1.list1.get(i) + ", Deser = " + obj2.list1.get(i));
			org.junit.Assert.assertEquals(obj1.list1.get(i), obj2.list1.get(i));
		}
	}

	public void serialize(Divine obj) throws IOException {
		byte[] data = obj.serialize();
		File file = new File("test/signed_int_test/java_test/bin.babel");
		try {
		    new FileOutputStream(file).write(data);
		} catch (Exception e) {
		    e.printStackTrace();
		}
	}

	public byte[] deserialize() throws IOException{
		File file = new File("test/signed_int_test/java_test/bin.babel");
		byte[] data = new byte[(int) file.length()];
		try {
		    new FileInputStream(file).read(data);
		} catch (Exception e) {
		    e.printStackTrace();
		}
		return data;
	}

}

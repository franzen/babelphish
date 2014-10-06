
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
	public void testDynamicInt() throws IOException {
        System.out.println("Test Dynamic Int63");
		DynamicInt ser = buildObj();
		
		serialize(ser);
		byte[] res = deserialize();

		DynamicInt deser = new DynamicInt();
		deser.deserialize(new ByteArrayInputStream(res));

		compare(ser, deser);
	}

	public DynamicInt buildObj() {
		DynamicInt obj = new DynamicInt();
		obj.list1   = new ArrayList<Long>(){{
			add(127L);
			add(16383L);
			add(2097151L);
			add(268435455L);
			add(34359738367L);
			add(4398046511103L);
			add(562949953421311L);
			//add(72057594037927935L);
			//add(9223372036854775807L);
		}};
		return obj;
	}

	public void compare(DynamicInt obj1, DynamicInt obj2) {
		for (int i = 0; i < obj1.list1.size(); i++){
	        	//System.out.println("Ser = " + obj1.list1.get(i) + ", Deser = " + obj2.list1.get(i));
			org.junit.Assert.assertEquals(obj1.list1.get(i), obj2.list1.get(i));
		}
	}

	public void serialize(Divine obj) throws IOException {
		byte[] data = obj.serialize();
		File file = new File("test/dynamic_int_test/java_test/bin.babel");
		try {
		    new FileOutputStream(file).write(data);
		} catch (Exception e) {
		    e.printStackTrace();
		}
	}

	public byte[] deserialize() throws IOException{
		File file = new File("test/dynamic_int_test/java_test/bin.babel");
		byte[] data = new byte[(int) file.length()];
		try {
		    new FileInputStream(file).read(data);
		} catch (Exception e) {
		    e.printStackTrace();
		}
		return data;
	}

}

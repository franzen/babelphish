
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
    public void testBasicTest() throws IOException {
		System.out.println("Test Basic Test");
		TestBasic testbasic_ser   = new TestBasic();
		TestBasic testbasic_deser = new TestBasic();

		testbasic_ser.i8   = 16;
		testbasic_ser.i16  = 458;
		testbasic_ser.i32  = 365248;
		testbasic_ser.str  = "Testing String";
		testbasic_ser.ip   = "";
		
		serialize(testbasic_ser);
		byte[] read = deserialize();
		testbasic_deser.deserialize(new ByteArrayInputStream(read));    

		org.junit.Assert.assertEquals(testbasic_ser.i8, testbasic_deser.i8);
		org.junit.Assert.assertEquals(testbasic_ser.i16, testbasic_deser.i16);
		org.junit.Assert.assertEquals(testbasic_ser.i32, testbasic_deser.i32);
		org.junit.Assert.assertEquals(testbasic_ser.str, testbasic_deser.str);
		org.junit.Assert.assertEquals(testbasic_ser.ip, testbasic_deser.ip);
    }
	
    @Test
    public void testComplexTest() throws IOException {
		TestComplex testcomplex_ser = new TestComplex();
		TestComplex testcomplex_deser = new TestComplex();
		testcomplex_ser.list1 = new ArrayList<Long>();
		testcomplex_ser.list1.add(123456L);
		testcomplex_ser.list1.add(654321L);
		
		testcomplex_ser.list2 = new ArrayList<Integer>();
		testcomplex_ser.list2.add(123);
		testcomplex_ser.list2.add(221);
		
		testcomplex_ser.map1 = new HashMap<Integer, Long>();
		testcomplex_ser.map1.put(12, 123456L);
		testcomplex_ser.map1.put(13, 6543231L);
		
		testcomplex_ser.map2 = new HashMap<String, ArrayList<Entry>>();
		ArrayList<Entry> tmp = new ArrayList<Entry>();
		tmp.add(new Entry());
		tmp.add(new Entry());
		testcomplex_ser.map2.put("Key_1", tmp);
		testcomplex_ser.map2.put("Key_2", tmp);
		
		serialize(testcomplex_ser);
		byte[] read = deserialize();
		testcomplex_deser.deserialize(new ByteArrayInputStream(read)); 

		org.junit.Assert.assertTrue (testcomplex_ser.list1.containsAll(testcomplex_deser.list1));
		org.junit.Assert.assertTrue (testcomplex_ser.list2.containsAll(testcomplex_deser.list2));
		for (Integer k : testcomplex_ser.map1.keySet()){
			org.junit.Assert.assertEquals(testcomplex_ser.map1.get(k), testcomplex_deser.map1.get(k)); 
		}
		for (String k : testcomplex_ser.map2.keySet()){
			org.junit.Assert.assertEquals(testcomplex_ser.map2.get(k).size(), testcomplex_deser.map2.get(k).size() ); 
		}
		
    }
    
    	public void serialize(Divine obj) throws IOException {
		byte[] data = obj.serialize();
		File file = new File("test/basic_complex_test/java_test/bin.babel");
		try {
		    new FileOutputStream(file).write(data);
		} catch (Exception e) {
		    e.printStackTrace();
		}
	}

	public byte[] deserialize() throws IOException{
		File file = new File("test/basic_complex_test/java_test/bin.babel");
		byte[] data = new byte[(int) file.length()];
		try {
		    new FileInputStream(file).read(data);
		} catch (Exception e) {
		    e.printStackTrace();
		}
		return data;
	}
    
}

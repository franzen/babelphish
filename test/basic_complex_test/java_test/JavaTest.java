import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import org.junit.*;



public class JavaTest {
	
	@Test
    public void testBasicTest() throws IOException {
		TestBasic testbasic_ser   = new TestBasic();
		TestBasic testbasic_deser = new TestBasic();
		testbasic_ser.i8   = 16;
		testbasic_ser.i16  = 458;
		testbasic_ser.i32  = 365248;
		testbasic_ser.str  = "Testing String";
		testbasic_ser.ip   = "";
		
		byte[] res = ser_deser(testbasic_ser);
		
		testbasic_deser.deserialize(new ByteArrayInputStream(res));
		
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
		
		byte[] res = ser_deser(testcomplex_ser);
		testcomplex_deser.deserialize(new ByteArrayInputStream(res));

		org.junit.Assert.assertTrue (testcomplex_ser.list1.containsAll(testcomplex_deser.list1));
		org.junit.Assert.assertTrue (testcomplex_ser.list2.containsAll(testcomplex_deser.list2));
		for (Integer k : testcomplex_ser.map1.keySet()){
			org.junit.Assert.assertEquals(testcomplex_ser.map1.get(k), testcomplex_deser.map1.get(k)); 
		}
		for (String k : testcomplex_ser.map2.keySet()){
			org.junit.Assert.assertEquals(testcomplex_ser.map2.get(k).size(), testcomplex_deser.map2.get(k).size() ); 
		}
		
    }
    
	public byte[] ser_deser(BabelBase obj) throws IOException{
		byte[] res = obj.serialize();
		Path file = FileSystems.getDefault().getPath("bin.babel");
		Files.write(file, res);
		res = Files.readAllBytes(file);
		return res;
	}
	
    public static junit.framework.Test suite() {
        return new junit.framework.JUnit4TestAdapter(JavaTest.class);
   }
    
    public static void main(String args[]) {
		org.junit.runner.JUnitCore.main("JavaTest");
    }
    
}

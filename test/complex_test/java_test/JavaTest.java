
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
	public void testComplexTest() throws IOException {
                System.out.println("Test Complex Data Structure");
		Complex complex_ser = buildObject();
		serialize(complex_ser);
		byte[] read = deserialize();

		Complex complex_deser = new Complex();
		complex_deser.deserialize(new ByteArrayInputStream(read));

		compare(complex_ser, complex_deser);
	}

	public Complex buildObject() {
		final IPList ipList_1 = new IPList();
		ipList_1.list1 = new ArrayList<String>() {
			{
				add("10.2.2.1");
				add("127.0.0.1");
				add("129.36.58.15");
			}	
		};

		ipList_1.list2 = new ArrayList<String>() {
			{
				add("2001:db8::ff00:1:8329");
				add("ff:ac:12::5f");
				add("1::");
			}
		};
		
		final IPList ipList_2 = new IPList();
		ipList_2.list1 = new ArrayList<String>() {
			{
				add("100.20.20.10");
				add("17.10.10.1");
				add("12.36.68.105");
			}
		};

		ipList_2.list2 = new ArrayList<String>() {
			{
				add("ff:fabf:faf:f15f:f1ff:f2f:1f:f2");
				add("2001:db8::ff00:1:8329");
				add("::1");
			}
		};
		
		Complex com = new Complex();
		com.list1 = new ArrayList<HashMap<String, ArrayList<IPList>>>() {
			{
				add(new HashMap<String, ArrayList<IPList>>() {
					{
						put("AA", new ArrayList<IPList>() {
							{
								add(ipList_1);
								add(ipList_2);
							}
						});
					}
				});
				add(new HashMap<String, ArrayList<IPList>>() {
					{
						put("BB", new ArrayList<IPList>() {
							{
								add(ipList_2);
								add(ipList_1);
							}
						});
					}
				});
			}
		};

		return com;
	}

	public void compare(Complex obj1, Complex obj2) {
		org.junit.Assert.assertEquals(obj1.list1.size(), obj2.list1.size());
		org.junit.Assert.assertEquals(obj1.list1.get(0).get("AA").size(),
				obj2.list1.get(0).get("AA").size());
		org.junit.Assert.assertEquals(obj1.list1.get(0).get("AA").get(0).list1
				.size(), obj2.list1.get(0).get("AA").get(0).list1.size());
		org.junit.Assert.assertEquals(obj1.list1.get(0).get("AA").get(0).list1
				.get(2), obj2.list1.get(0).get("AA").get(0).list1.get(2));
		org.junit.Assert.assertEquals(obj1.list1.get(0).get("AA").get(0).list2
				.get(1), obj2.list1.get(0).get("AA").get(0).list2.get(1));
		org.junit.Assert.assertEquals(obj1.list1.get(1).get("BB").get(0).list2
				.get(0), obj2.list1.get(1).get("BB").get(0).list2.get(0));
	}

	public void serialize(BabelBase obj) throws IOException {
		byte[] data = obj.serialize();
		File file = new File("test/complex_test/java_test/bin.babel");
		try {
		    new FileOutputStream(file).write(data);
		} catch (Exception e) {
		    e.printStackTrace();
		}
	}

	public byte[] deserialize() throws IOException{
		File file = new File("test/complex_test/java_test/bin.babel");
		byte[] data = new byte[(int) file.length()];
		try {
		    new FileInputStream(file).read(data);
		} catch (Exception e) {
		    e.printStackTrace();
		}
		return data;
	}

}

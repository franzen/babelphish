import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import org.junit.*;

public class JavaTest {

	@Test
	public void testComplexTest() throws IOException {
		Complex binartTree_ser = buildObject();
		byte[] res = ser_deser(binartTree_ser);

		Complex binartTree_deser = new Complex();
		binartTree_deser.deserialize(new ByteArrayInputStream(res));

		compare(binartTree_ser, binartTree_deser);
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

		final IPList ipList_2 = new IPList();
		ipList_2.list1 = new ArrayList<String>() {
			{
				add("100.20.20.10");
				add("17.10.10.1");
				add("12.36.68.105");
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
	}

	public byte[] ser_deser(BabelBase obj) throws IOException {
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

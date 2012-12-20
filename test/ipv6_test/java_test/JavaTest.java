
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
	public void testIpv6Test() throws IOException {
                System.out.println("Test IPv6");
		IPV6 ipv6_ser = buildObj();
		
		serialize(ipv6_ser);
		byte[] res = deserialize();

		IPV6 ipv6_deser = new IPV6();
		ipv6_deser.deserialize(new ByteArrayInputStream(res));

		compare(ipv6_ser, ipv6_deser);
	}

	public IPV6 buildObj() {
		IPV6 obj = new IPV6();
		obj.list1   = new ArrayList<String>(){{
			add("255.102.0.25");
			add("ff:fabf:faf:f15f:f1ff:f2f:1f:f2");
		}};
		
		// Should Success
//	    obj.ip = "2001:db8::ff00:1:8329";
//	    obj.ip = "F::";
//	    obj.ip = "::1";
//	    obj.ip = "";
		    
	    // Should Fail or raise error
//	    obj.ip = "2001:0db8:0000:0000:0000:ff00:0042:8329";
//	    obj.ip = "2001:db8:::ff00:42:8329";
//		obj.ip = "2001:db8::fff00:42:8329";
//	    obj.ip = "2001:db8:ff00:42:8329";
//	    obj.ip = "::";
		
		return obj;
	}

	public void compare(IPV6 obj1, IPV6 obj2) {
		org.junit.Assert.assertEquals(obj1.list1.get(0), obj2.list1.get(0));
		org.junit.Assert.assertEquals(obj1.list1.get(1), obj2.list1.get(1));
	}

	public void serialize(BabelBase obj) throws IOException {
		byte[] data = obj.serialize();
		File file = new File("test/ipv6_test/java_test/bin.babel");
		try {
		    new FileOutputStream(file).write(data);
		} catch (Exception e) {
		    e.printStackTrace();
		}
	}

	public byte[] deserialize() throws IOException{
		File file = new File("test/ipv6_test/java_test/bin.babel");
		byte[] data = new byte[(int) file.length()];
		try {
		    new FileInputStream(file).read(data);
		} catch (Exception e) {
		    e.printStackTrace();
		}
		return data;
	}

}

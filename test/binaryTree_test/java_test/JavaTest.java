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
		BinaryTree binartTree_ser = buildTree();
		byte[] res = ser_deser(binartTree_ser);

		BinaryTree binartTree_deser = new BinaryTree();
		binartTree_deser.deserialize(new ByteArrayInputStream(res));

		compareBinaryTree(binartTree_ser, binartTree_deser);
	}

	public BinaryTree buildTree() {
		final Node root = new Node();
		root.i32 = 0;

		final Node n1_L = new Node();
		n1_L.i32 = 1;

		final Node n1_R = new Node();
		n1_R.i32 = 2;

		final Node n2_L_L = new Node();
		n2_L_L.i32 = 3;

		final Node n2_L_R = new Node();
		n2_L_R.i32 = 4;

		final Node n2_R_L = new Node();
		n2_R_L.i32 = 5;

		final Node n2_R_R = new Node();
		n2_R_R.i32 = 6;

		root.next_node = new ArrayList<Node>() {
			{
				add(n1_L);
				add(n1_R);
			}
		};

		n1_L.next_node = new ArrayList<Node>() {
			{
				add(n2_L_L);
				add(n2_L_R);
			}
		};

		n1_R.next_node = new ArrayList<Node>() {
			{
				add(n2_R_L);
				add(n2_R_R);
			}
		};

		BinaryTree bt = new BinaryTree();
		bt.root_node = new ArrayList<Node>() {
			{
				add(root);
			}
		};

		return bt;
	}

	public void compareBinaryTree(BinaryTree bt1, BinaryTree bt2) {
		org.junit.Assert.assertEquals(bt1.root_node.size(), bt2.root_node
				.size());
		org.junit.Assert.assertEquals(bt1.root_node.get(0).i32, bt2.root_node
				.get(0).i32);
		org.junit.Assert.assertEquals(bt1.root_node.get(0).next_node.size(),
				bt2.root_node.get(0).next_node.size());
		org.junit.Assert.assertEquals(
				bt1.root_node.get(0).next_node.get(0).next_node.get(0).i32,
				bt2.root_node.get(0).next_node.get(0).next_node.get(0).i32);
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

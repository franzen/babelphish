using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using divine;
using NUnit.Framework;

namespace test_signed_int
{
    [TestFixture]
    class divine
    {
        [Test]
        public static void Main(String[] args)
        {
	    System.Console.Write("Test Binary Tree  \n");
            BinaryTree ser = buildObj();
            serialize(ser);
            byte[] res = deserialize();

            BinaryTree deser = new BinaryTree();
            deser.deserialize(new MemoryStream(res));

            compare(ser, deser);            
        }

        public static BinaryTree buildObj() {
		Node root = new Node();
		root.i32 = 0;

		Node n1_L = new Node();
		n1_L.i32 = 1;

		Node n1_R = new Node();
		n1_R.i32 = 2;

		Node n2_L_L = new Node();
		n2_L_L.i32 = 3;

		Node n2_L_R = new Node();
		n2_L_R.i32 = 4;

		Node n2_R_L = new Node();
		n2_R_L.i32 = 5;

		Node n2_R_R = new Node();
		n2_R_R.i32 = 6;

		root.next_node.Add(n1_L);
		root.next_node.Add(n1_R);

		n1_L.next_node.Add(n2_L_L);
		n1_L.next_node.Add(n2_L_R);

		n1_R.next_node.Add(n2_R_L);
		n1_R.next_node.Add(n2_R_R);

		BinaryTree bt = new BinaryTree();
		bt.root_node.Add(root);

            return bt;
	    }

        public static void compare(BinaryTree bt1, BinaryTree bt2)
        {
            Assert.AreEqual(bt1.root_node.Count, bt2.root_node.Count);
	    Assert.AreEqual(bt1.root_node[0].i32, bt2.root_node[0].i32);
	    Assert.AreEqual(bt1.root_node[0].next_node.Count, bt2.root_node[0].next_node.Count);
	    Assert.AreEqual(bt1.root_node[0].next_node[0].next_node[0].i32,
				bt2.root_node[0].next_node[0].next_node[0].i32);
        }

        public static void serialize(Divine obj)
        {
            try
            {
                byte[] data = obj.serialize();
                File.WriteAllBytes("test/binaryTree_test/csharp_test/bin.babel.csharp", data);                
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
	    }

	    public static byte[] deserialize(){
            try
            {
                byte[] data = File.ReadAllBytes("test/binaryTree_test/csharp_test/bin.babel.csharp");
                return data;
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
	    }
            
    }
}

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
	    System.Console.Write("Test IPv6 \n");
            IPV6 ser = buildObj();
            serialize(ser);
            byte[] res = deserialize();

            IPV6 deser = new IPV6();
            deser.deserialize(new MemoryStream(res));

            compare(ser, deser);            
        }

        public static IPV6 buildObj() {
		IPV6 obj = new IPV6();
		obj.list1.Add("255.102.0.25");
		obj.list1.Add("ff:fabf:faf:f15f:f1ff:f2f:1f:f2");
		obj.list1.Add("2001:db8::ff00:1:8329");
		obj.list1.Add("f::");
		obj.list1.Add("::1");
		obj.list1.Add("");
            return obj;
	    }

        public static void compare(IPV6 obj1, IPV6 obj2)
        {
            for (int i = 0; i < obj1.list1.Count; i++)
            {
                //System.Console.Write("Ser = " + obj1.list1[i] + ", Deser = " + obj2.list1[i] + "\n");
                Assert.AreEqual(obj1.list1[i].ToLower(), obj2.list1[i].ToLower());
            }
        }

        public static void serialize(Divine obj)
        {
            try
            {
                byte[] data = obj.serialize();
                File.WriteAllBytes("test/ipv6_test/csharp_test/bin.babel.csharp", data);                
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
	    }

	    public static byte[] deserialize(){
            try
            {
                byte[] data = File.ReadAllBytes("test/ipv6_test/csharp_test/bin.babel.csharp");
                return data;
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
	    }
            
    }
}

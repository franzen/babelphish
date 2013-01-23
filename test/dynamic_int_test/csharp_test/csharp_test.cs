using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using divine;
using NUnit.Framework;

namespace test_dynamic_int
{
    [TestFixture]
    class divine
    {
        [Test]
        public static void Main(String[] args)
        {
	    System.Console.Write("Test Dynamic Int  \n");
            DynamicInt ser = buildObj();
            serialize(ser);
            byte[] res = deserialize();

            DynamicInt deser = new DynamicInt();
            deser.deserialize(new MemoryStream(res));

            compare(ser, deser);            
        }

        public static DynamicInt buildObj() {
		DynamicInt obj = new DynamicInt();
		obj.list1.Add(127);
		obj.list1.Add(16383);
		obj.list1.Add(2097151);
		obj.list1.Add(268435455);
		obj.list1.Add(34359738367);
		obj.list1.Add(4398046511103);
		obj.list1.Add(562949953421311);
		obj.list1.Add(72057594037927935);
		obj.list1.Add(9223372036854775807);
            return obj;
	    }

        public static void compare(DynamicInt obj1, DynamicInt obj2)
        {
            for (int i = 0; i < obj1.list1.Count; i++)
            {
                //System.Console.Write("Ser = " + obj1.list1[i] + ", Deser = " + obj2.list1[i] + "\n");
                Assert.AreEqual(obj1.list1[i], obj2.list1[i]);
            }
        }

        public static void serialize(Divine obj)
        {
            try
            {
                byte[] data = obj.serialize();
                File.WriteAllBytes("test/dynamic_int_test/csharp_test/bin.babel.csharp", data);                
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
	    }

	    public static byte[] deserialize(){
            try
            {
                byte[] data = File.ReadAllBytes("test/dynamic_int_test/csharp_test/bin.babel.csharp");
                return data;
            }
            catch (System.IO.IOException ex)
            {
                throw ex;
            }
	    }
            
    }
}

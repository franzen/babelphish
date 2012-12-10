import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.HashMap;

abstract class BabelBase  {
	private static final Charset UTF8 = Charset.forName("UTF-8");

	public byte[] serialize() throws IOException {
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		serializeInternal(baos);
		baos.close();
		return baos.toByteArray();
	}

	abstract void serializeInternal(ByteArrayOutputStream baos) throws IOException;

	abstract void deserialize(ByteArrayInputStream baos) throws IOException;

	protected int readInt8(ByteArrayInputStream data) {
		return data.read() & 0xff;
	}

	protected int readInt16(ByteArrayInputStream data) {
		return (data.read() << 8) | readInt8(data);
	}

	protected int readInt24(ByteArrayInputStream data) {
		return (data.read() << 16) | readInt16(data);
	}

	protected long readInt32(ByteArrayInputStream data) {
		return (data.read() << 24) | readInt24(data);
	}

	protected boolean readBool(ByteArrayInputStream data) {
		return readInt8(data) == 1;
	}

	protected String readString(ByteArrayInputStream data) throws IOException {
		// Force utf8
		return new String(readBytes(readInt16(data), data), UTF8);
	}

	private byte[] readBytes(int size, ByteArrayInputStream data) throws IOException {
		byte[] bs = new byte[size];
		data.read(bs);
		return bs;
	}

	protected byte[] readBinary(ByteArrayInputStream data) throws IOException {
		long c = readInt32(data);
		if (c > Integer.MAX_VALUE) {
			throw new IndexOutOfBoundsException("Binary data to big for java");
		}
		return readBytes((int) c, data);
	}

	protected byte[] readShortBinary(ByteArrayInputStream data) throws IOException {
		return readBytes(readInt8(data), data);
	}

	protected String readIpNumber(ByteArrayInputStream data) throws IOException {
		byte[] ips = readShortBinary(data);
		String ip = "";
		for (byte b : ips) {
			if (ip.length() > 0) {
				ip += ".";
			}
			ip += (b & 0xFF);
		}
		return ip;
	}

	protected void writeInt8(int v, ByteArrayOutputStream out) {
		if (v > 0xFF) { // Max 255
			raiseError("Too large int8 number: " + v);
		}
		out.write(v);
	}

	protected void writeInt16(int v, ByteArrayOutputStream out) {
		if (v > 0xFFFF) { // Max 65.535 
			raiseError("Too large int16 number: " + v);
		}
		writeInt8(v >> 8 & 0xFF, out);
		writeInt8(v & 0xFF, out);
	}

	protected void writeInt24(int v, ByteArrayOutputStream out) {
		if (v > 0xFFFFFF) { // Max 16.777.215
			raiseError("Too large int24 number: " + v);
		}
		writeInt8(v >> 16 & 0xFF, out);
		writeInt16(v & 0xFFFF, out);
	}

	protected void writeInt32(long v, ByteArrayOutputStream out) {
		if (v > 0xFFFFFFFFL) { // Max 4.294.967.295
			raiseError("Too large int32 number: " + v);
		}
		writeInt8((int) ((v >> 24) & 0xFF), out);
		writeInt24((int) (v & 0xFFFFFF), out);
	}

	protected void writeBool(boolean v, ByteArrayOutputStream out) {
		writeInt8(v ? 1 : 0, out);
	}

	protected void writeString(String v, ByteArrayOutputStream out) throws IOException {
		byte[] bs = v.getBytes(UTF8);
		if (bs.length > 0xFFFF) {
			raiseError("Too large string: " + bs.length + " bytes");
		}
		writeInt16(bs.length, out);
		out.write(bs);
	}

	protected void writeBinary(byte[] v, ByteArrayOutputStream out) throws IOException {
		if (v.length > 0xFFFFFFFFL) {
			raiseError("Too large binary: " + v.length + " bytes");
		}
		writeInt32(v.length, out);
		out.write(v);
	}

	protected void writeShortBinary(byte[] v, ByteArrayOutputStream out) throws IOException {
		if (v.length > 0xFF) {
			raiseError("Too large short_binary: " + v.length + " bytes");
		}
		writeInt8(v.length, out);
		out.write(v);
	}

	protected void writeIpNumber(String v, ByteArrayOutputStream out) throws IOException {
		byte[] ss = new byte[0];
		if(!v.isEmpty()){
			String[] bs = v.split("\\.");
			ss = new byte[bs.length];
			for (int i = 0; i < bs.length; i++) {
				ss[i] = (byte) (Integer.parseInt(bs[i]) & 0xFF);
			}
		}
		if (ss.length == 0 || ss.length == 4) {
			writeShortBinary(ss, out);
		} else {
			raiseError("Unknown IP v4 number " + v); // Only IPv4 for now 
		}
	}

	protected void raiseError(String msg) {
		throw new IllegalArgumentException("[" + this.getClass().getCanonicalName() + "] " + msg);
	}
}


class Complex extends BabelBase {
	public ArrayList<HashMap<String, ArrayList<IPList>>> list1 = new ArrayList<HashMap<String, ArrayList<IPList>>>();

	@Override
	void serializeInternal(ByteArrayOutputStream baos) throws IOException {
		// Serialize list 'list1'
		writeInt32(list1.size(), baos);
		for(int var_101=0; var_101<list1.size(); var_101++) {
			HashMap<String, ArrayList<IPList>> var_100 = list1.get(var_101);
			writeInt32(var_100.size(), baos);
			for(String var_102 : var_100.keySet()) {
				ArrayList<IPList> var_103 = var_100.get(var_102);
				writeString(var_102, baos);
				writeInt32(var_103.size(), baos);
				for(int var_105=0; var_105<var_103.size(); var_105++) {
					IPList var_104 = var_103.get(var_105);
					var_104.serializeInternal(baos);
				}
			}
		}
	}

	@Override
	void deserialize(ByteArrayInputStream bais) throws IOException {
		// Deserialize list 'list1'
		this.list1 = new ArrayList<HashMap<String, ArrayList<IPList>>>();
		int var_106 = (int)this.readInt32(bais);
		for(int var_108=0; var_108<var_106; var_108++) {
			HashMap<String, ArrayList<IPList>> var_107 = new HashMap<String, ArrayList<IPList>>();
			int var_109 = (int)readInt32(bais);
			for(int var_10c=0; var_10c<var_109; var_10c++) {
				String var_10a = readString(bais);
				ArrayList<IPList> var_10b = new ArrayList<IPList>();
				int var_10d = (int)this.readInt32(bais);
				for(int var_10f=0; var_10f<var_10d; var_10f++) {
					IPList var_10e = new IPList();
					var_10e.deserialize(bais);
					var_10b.add(var_10e);
				}
				var_107.put(var_10a, var_10b);
			}
			this.list1.add(var_107);
		}
	}
}


class IPList extends BabelBase {
	public ArrayList<String> list1 = new ArrayList<String>();

	@Override
	void serializeInternal(ByteArrayOutputStream baos) throws IOException {
		// Serialize list 'list1'
		writeInt32(list1.size(), baos);
		for(int var_111=0; var_111<list1.size(); var_111++) {
			String var_110 = list1.get(var_111);
			writeIpNumber(var_110, baos);
		}
	}

	@Override
	void deserialize(ByteArrayInputStream bais) throws IOException {
		// Deserialize list 'list1'
		this.list1 = new ArrayList<String>();
		int var_112 = (int)this.readInt32(bais);
		for(int var_114=0; var_114<var_112; var_114++) {
			String var_113 = readIpNumber(bais);
			this.list1.add(var_113);
		}
	}
}

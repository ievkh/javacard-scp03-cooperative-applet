package io.github.ievkh.scpapplet;

import javacard.framework.*;
import org.globalplatform.GPSystem;
import org.globalplatform.SecureChannel;

// Cooperative SCP applet. Targets GP Card API v1.6 / GPCS v2.3.1.
// Library-facing contract: org.globalplatform.SecureChannel (GP Card API v1.6
// §4).
public final class HelloWorld extends Applet {
  private static final byte INS_INITIALIZE_UPDATE = (byte)0x50;
  private static final byte INS_EXTERNAL_AUTHENTICATE = (byte)0x82;
  private static final byte INS_BEGIN_RMAC_SESSION =
      (byte)0x7A; // SCP02 R-MAC (GPCS §E.6)
  private static final byte INS_END_RMAC_SESSION =
      (byte)0x78; // SCP02 R-MAC (GPCS §E.6)
  private static final byte INS_HELLO = (byte)0xF0;

  private static final byte[] HELLO_BYTES = {'H', 'e', 'l', 'l', 'o', ' ',
                                             'W', 'o', 'r', 'l', 'd'};

  private HelloWorld() { register(); }

  public static void install(byte[] bArray, short bOffset, byte bLength) {
    new HelloWorld();
  }

  @Override
  public void process(APDU apdu) {
    if (selectingApplet())
      return;

    byte[] buf = apdu.getBuffer();
    byte ins = buf[ISO7816.OFFSET_INS];
    SecureChannel sc = GPSystem.getSecureChannel();

    // SCP channel setup — delegate to Security Domain (GPCS §7.1.2; GP Card API
    // v1.6 §4.1.7)
    if (ins == INS_INITIALIZE_UPDATE || ins == INS_EXTERNAL_AUTHENTICATE ||
        ins == INS_BEGIN_RMAC_SESSION || ins == INS_END_RMAC_SESSION) {
      apdu.setOutgoingAndSend(ISO7816.OFFSET_CDATA, sc.processSecurity(apdu));
      return;
    }

    // Application command: receive, unwrap, check auth, dispatch, wrap response
    apdu.setIncomingAndReceive();
    sc.unwrap(buf, ISO7816.OFFSET_CLA,
              (short)(apdu.getOffsetCdata() + apdu.getIncomingLength()));

    if ((sc.getSecurityLevel() & SecureChannel.AUTHENTICATED) == 0) {
      ISOException.throwIt(ISO7816.SW_SECURITY_STATUS_NOT_SATISFIED);
    }

    short responseLen;
    switch (ins) {
    case INS_HELLO:
      Util.arrayCopyNonAtomic(HELLO_BYTES, (short)0, buf, ISO7816.OFFSET_CDATA,
                              (short)HELLO_BYTES.length);
      responseLen = (short)HELLO_BYTES.length;
      break;
    default:
      ISOException.throwIt(ISO7816.SW_INS_NOT_SUPPORTED);
      return;
    }

    // Apply response secure messaging ONLY when the session actually negotiated
    // R-MAC. In SCP03, R-ENCRYPTION is never set without R-MAC, so testing
    // R_MAC alone is sufficient. (GP Card API v1.6 §4.1.12)
    //
    //  - R-MAC in force: the applet must append the expected SW so it is
    //    covered by R-MAC / R-ENC, then call wrap(); wrap() returns the
    //    protected length (encrypted data + R-MAC). The JCRE appends the
    //    transport SW.
    //  - R-MAC NOT in force: wrap() would apply no cryptographic processing,
    //    so appending the SW here would leak a spurious extra status word into
    //    the response data (the cause of the "... 9000 9000" seen on the wire).
    //    Instead, send the plain data and let the JCRE append the SW.
    if ((sc.getSecurityLevel() &
         (SecureChannel.R_MAC | SecureChannel.R_ENCRYPTION)) != 0) {
      Util.setShort(buf, (short)(ISO7816.OFFSET_CDATA + responseLen),
                    ISO7816.SW_NO_ERROR);
      responseLen =
          sc.wrap(buf, ISO7816.OFFSET_CDATA, (short)(responseLen + 2));
    }
    apdu.setOutgoingAndSend(ISO7816.OFFSET_CDATA, responseLen);
  }
}
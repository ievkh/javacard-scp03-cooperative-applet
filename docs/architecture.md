# Architecture

The applet implements the cooperative SCP model used by GlobalPlatform Card
Specification deployments.

Secure messaging cryptographic processing is delegated to the Security Domain
through `org.globalplatform.SecureChannel`.

The applet:

- passes SCP session-establishment commands to the Security Domain,
- unwraps incoming application APDUs,
- validates authenticated secure messaging state,
- processes plaintext application commands,
- wraps responses when response secure messaging is active.

## Flow

```text
OCE / GPPro
    |
    |  SCP03 secure messaging
    v
Security Domain / SSD
    |
    |  GP Card API SecureChannel
    v
Cooperative Applet
    |
    v
Application Logic
```

## Applet Command

The reference command is:

```text
CLA=80 INS=F0 P1=00 P2=00 Data="Hello"
```

Expected plaintext application response:

```text
Hello World
```

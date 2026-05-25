# javacard-scp03-cooperative-applet

Reference cooperative SCP03 Java Card applet demonstrating integration with
GlobalPlatform `SecureChannel` services and SSD-based deployment workflows.

The project targets:

- Oracle Java Card Simulator
- Real GlobalPlatform-compatible Java Cards
- Stock GPPro deployment workflows
- SCP03 cooperative secure channel handling

## Features

- Cooperative SCP03 handling through `org.globalplatform.SecureChannel`
- SSD-oriented deployment flow
- GPPro-compatible helper scripts
- Java Card SDK × GP API build matrix
- Minimal reference applet implementation
- SCP03 secure messaging validation

## Repository Layout

```text
src/       Java Card applet source
scripts/   GPPro deployment helper scripts
docs/      architecture notes
build.sh   matrix build script
env.example.sh  local environment template
```

## Requirements

- JDK 8
- Oracle Java Card SDK
- GP Card API export files and API JARs
- GPPro

## Build

Create a local environment file:

```sh
cp env.example.sh env.sh
$EDITOR env.sh
```

Build all configured Java Card SDK × GP API combinations:

```sh
./build.sh
```

Artifacts are generated under:

```text
out/jc<version>-<gp-version>/
```

## Deployment Flow

Typical SSD workflow:

```sh
./scripts/10-create-ssd.sh
./scripts/20-put-ssd-scp03-keys.sh
./scripts/30-install-applet.sh
./scripts/40-send-hello.sh
```

The scripts print the GPPro command before executing it. Review `env.sh` and
replace all example keys before use with a real card.

## Security Notes

This applet implements the cooperative secure channel model:

- SCP cryptographic processing is delegated to the Security Domain.
- The applet validates the authenticated secure messaging state.
- APDU wrapping and unwrapping use GP Card API `SecureChannel` services.

The project is intended for development, interoperability testing, and
GlobalPlatform research workflows.

## References

- GlobalPlatform Card Specification 2.3.1
- GlobalPlatform Card API 1.6
- Oracle Java Card SDK
- GPPro

## License

MIT

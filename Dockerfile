# FROM rust:1.56.0 AS cacher
FROM ekidd/rust-musl-builder:stable AS builder

WORKDIR /user/rust-template
COPY Cargo.toml Cargo.toml

# for caching
COPY Cargo.toml Cargo.toml
RUN mkdir src
RUN echo 'fn main(){println!("cached!")}' > src/main.rs

RUN cargo build --release

# copy code
COPY src/ src

# for recompile
RUN rm -f target/x86_64-unknown-linux-musl/release/deps/main*

RUN rm -f target/x86_64-unknown-linux-musl/release/deps/libmain*

RUN cargo build --release --target x86_64-unknown-linux-musl
RUN strip /user/rust-template/target/x86_64-unknown-linux-musl/release/main

# FROM ekidd/rust-musl-builder:stable
FROM rust:1.57-slim

COPY --from=builder \
    /user/rust-template/target/x86_64-unknown-linux-musl/release/main /
RUN mkdir target

ENTRYPOINT [ "/main" ]
FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev wget git cmake \
    autoconf automake autotools-dev libtool \
    ninja-build python3 python3-pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV OQSPROVIDER_TAG=0.8.0
ENV OPENSSL_BRANCH=openssl-3.4.0
ENV LIBOQS_BRANCH=0.12.0
ENV MAKE_PARAMS=-j8

WORKDIR /opt/
RUN git clone --single-branch https://github.com/open-quantum-safe/oqs-provider.git oqsprovider-${OQSPROVIDER_TAG} && \
    cd oqsprovider-${OQSPROVIDER_TAG} && \
    git checkout ${OQSPROVIDER_TAG} 

WORKDIR /opt/oqsprovider-${OQSPROVIDER_TAG}
COPY <<-"EOT" pip.patch
diff --git a/scripts/fullbuild.sh b/scripts/fullbuild.sh
index 097aa06..f0d90de 100755
--- a/scripts/fullbuild.sh
+++ b/scripts/fullbuild.sh
@@ -90,6 +90,8 @@ if [ -z $liboqs_DIR ]; then
     if [ "$LIBOQS_BRANCH" != "main" ]; then
       # check for presence of backwards-compatibility generator file
       if [ -f oqs-template/generate.yml-$LIBOQS_BRANCH ]; then
+        echo "Download pip dependencies for $LIBOQS_BRANCH"
+        pip install -r oqs-template/requirements.txt
         echo "generating code for $LIBOQS_BRANCH"
         mv oqs-template/generate.yml oqs-template/generate.yml-main
         cp oqs-template/generate.yml-$LIBOQS_BRANCH oqs-template/generate.yml
EOT
RUN git apply pip.patch -v && \
    ./scripts/fullbuild.sh

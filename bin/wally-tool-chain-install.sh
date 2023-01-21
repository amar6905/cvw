export RISCV=/opt/riscv
export PATH=$PATH:$RISCV/bin

NUM_THREADS=4

# UPDATE / UPGRADE
apt update

# INSTALL 
apt install -y git gawk make texinfo bison flex build-essential python libz-dev libexpat-dev autoconf device-tree-compiler ninja-build libpixman-1-dev build-essential ncurses-base ncurses-bin libncurses5-dev dialog curl wget ftp libgmp-dev 

# gcc cross-compiler
git clone https://github.com/riscv/riscv-gnu-toolchain && \
    cd riscv-gnu-toolchain && \
    ./configure --prefix=${RISCV} --enable-multilib --with-multilib-generator="rv32e-ilp32e--;rv32i-ilp32--;rv32im-ilp32--;rv32iac-ilp32--;rv32imac-ilp32--;rv32imafc-ilp32f--;rv32imafdc-ilp32d--;rv64i-lp64--;rv64ic-lp64--;rv64iac-lp64--;rv64imac-lp64--;rv64imafdc-lp64d--;rv64im-lp64--;" && \
    make -j $(NUM_THREADS) && \
    make install

# elf2hex
export PATH=$RISCV/riscv-gnu-toolchain/bin:$PATH
git clone https://github.com/sifive/elf2hex.git && \
  cd elf2hex && \
  autoreconf -i && \
  ./configure --target=riscv64-unknown-elf --prefix=$RISCV && \
  make && \
  make install

# Update Python3.6 for QEMU
apt-get -y update
apt-get -y install python3-pip
apt-get -y install pkg-config
apt-get -y install libglib2.0-dev

# QEMU
git clone --recurse-submodules https://github.com/qemu/qemu && \
  cd qemu && \
  ./configure --target-list=riscv64-softmmu --prefix=$RISCV  && \
  make -j $(NUM_THREADS) && \
  make install

# Spike
git clone https://github.com/riscv-software-src/riscv-isa-sim && \
  mkdir riscv-isa-sim/build && \
  cd riscv-isa-sim/build && \
  ../configure --prefix=$RISCV --enable-commitlog && \
  make -j $(NUM_THREADS) && \
  make install  && \
  cd ../arch_test_target/spike/device && \
  sed -i 's/--isa=rv32ic/--isa=rv32iac/' rv32i_m/privilege/Makefile.include && \
  sed -i 's/--isa=rv64ic/--isa=rv64iac/' rv64i_m/privilege/Makefile.include

# SAIL
apt-get install -y opam  build-essential libgmp-dev z3 pkg-config zlib1g-dev && \
  git clone https://github.com/Z3Prover/z3.git && \
  cd z3 && \
  python scripts/mk_make.py && \
  cd build && \
  make  -j $(NUM_THREADS)  && \
  make install && \
  cd ../.. && \
  pip3 install chardet==3.0.4 && \
  pip3 install urllib3==1.22 && \
  opam init -y --disable-sandboxing && \
  opam switch create ocaml-base-compiler.4.06.1 && \
  opam install sail -y 

eval $(opam config env) && \
  git clone https://github.com/riscv/sail-riscv.git && \
  cd sail-riscv && \
  make -j $(NUM_THREADS) && \
  ARCH=RV32 make -j $(NUM_THREADS) && \
  ARCH=RV64 make -j $(NUM_THREADS)  && \
  ln -s $RISCV/sail-riscv/c_emulator/riscv_sim_RV64 /usr/bin/riscv_sim_RV64 && \
  ln -s $RISCV/sail-riscv/c_emulator/riscv_sim_RV32 /usr/bin/riscv_sim_RV32

pip3 install testresources && \
  pip3 install riscof --ignore-installed PyYAML

# Verilator
apt install verilator


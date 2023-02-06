DATE=$(date +"%Y%m%d-$RANDOM")
KERNEL_NAME=mrack-cepheus-"$DATE"

export KERNEL_PATH=$PWD
export ANYKERNEL_PATH=$PWD/Anykernel3
export CLANG_PATH=$PWD/prelude-clang
export PATH=${CLANG_PATH}/bin:${PATH}
export CLANG_TRIPLE=aarch64-linux-gnu-
export ARCH=arm64
export SUBARCH=arm64
export LLVM=1
export LLVM_IAS=1

echo "===================Setup Environment==================="
git clone --depth=1 https://github.com/kdrag0n/proton-clang $CLANG_PATH
git clone https://github.com/osm0sis/AnyKernel3 $ANYKERNEL_PATH

echo "=========================Clean========================="
rm -rf $KERNEL_PATH/out/ *.zip
echo "=========================Build========================="
# make mrproper
make O=out CC="ccache clang" CXX="ccache clang++" CROSS_COMPILE=$CLANG_PATH/bin/aarch64-linux-gnu- CROSS_COMPILE_ARM32=$CLANG_PATH/bin/arm-linux-gnueabi- LD=ld.lld cepheus_docker_defconfig
make O=out CC="ccache clang" CXX="ccache clang++" CROSS_COMPILE=$CLANG_PATH/bin/aarch64-linux-gnu- CROSS_COMPILE_ARM32=$CLANG_PATH/bin/arm-linux-gnueabi- LD=ld.lld 2>&1 | tee out/kernel.log

if [ ! -e $KERNEL_PATH/out/arch/arm64/boot/Image.gz-dtb ]; then
    echo "=======================FAILED!!!======================="
    rm -rf $ANYKERNEL_PATH
    exit -1>/dev/null 2>&1
fi

echo "=========================Patch========================="
rm -r $ANYKERNEL_PATH/modules $ANYKERNEL_PATH/patch $ANYKERNEL_PATH/ramdisk
cp $KERNEL_PATH/anykernel.sh $ANYKERNEL_PATH/
cp $KERNEL_PATH/out/arch/arm64/boot/Image.gz-dtb $ANYKERNEL_PATH/
cd $ANYKERNEL_PATH
zip -r $KERNEL_NAME *
mv $KERNEL_NAME.zip $KERNEL_PATH/out/
cd $KERNEL_PATH
rm -rf $ANYKERNEL_PATH
echo $KERNEL_NAME.zip


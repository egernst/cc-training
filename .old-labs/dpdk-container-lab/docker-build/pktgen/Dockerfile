FROM ses2017/pktgen
COPY ./dpdk-container-lab /root/dpdk-container-lab
WORKDIR /root/dpdk-container-lab
COPY ./dpdk /usr/src/dpdk
COPY ./pktgen /usr/src/pktgen
ENV DPDK_DIR "/usr/src/dpdk"
ENV DPDK_BUILD "x86_64-native-linuxapp-gcc"
ENV RTE_SDK "/usr/src/dpdk"
ENV RTE_TARGET "x86_64-native-linuxapp-gcc"
ENV PKTGEN_DIR "/usr/src/pktgen"
ENV TRAINING_DIR "/root/dpdk-container-lab"
RUN ./build_dpdk.sh
RUN ./build_pktgen.sh
CMD ["/bin/bash"]

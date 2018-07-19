FROM ros:indigo

MAINTAINER iory ab.ioryz@gmail.com

ENV ROS_DISTRO indigo

RUN apt update && \
DEBIAN_FRONTEND=noninteractive apt install -y \
wget \
python-rosinstall \
python-catkin-tools \
libpopt-dev \
swig \
ros-${ROS_DISTRO}-jsk-tools && \
rm -rf /var/lib/apt/lists/*

ENV PEAK_LINUX_DRIVER_VERSION peak-linux-driver-7.15.2
RUN wget http://www.peak-system.com/fileadmin/media/linux/files/${PEAK_LINUX_DRIVER_VERSION}.tar.gz
RUN tar xvzf ${PEAK_LINUX_DRIVER_VERSION}.tar.gz
RUN cd ${PEAK_LINUX_DRIVER_VERSION} && make NET=NO_NETDEV_SUPPORT && make install

RUN git clone https://github.com/RobotnikAutomation/pcan_python && \
    cd pcan_python && \
    make && \
    make install

RUN mkdir -p /catkin_ws/src && \
    git clone -b ${ROS_DISTRO}-devel https://github.com/RobotnikAutomation/barrett_hand /catkin_ws/src/barrett_hand
RUN mv /bin/sh /bin/sh_tmp && ln -s /bin/bash /bin/sh
RUN source /opt/ros/${ROS_DISTRO}/setup.bash; cd /catkin_ws; catkin build
RUN rm /bin/sh && mv /bin/sh_tmp /bin/sh
RUN touch /root/.bashrc && \
    echo "source /catkin_ws/devel/setup.bash\n" >> /root/.bashrc && \
    echo "rossetip\n" >> /root/.bashrc && \
    echo "rossetmaster localhost\n" && \
    echo 'export PYTHONPATH=/usr/lib:"$PYTHONPATH"\n' >> /root/.bashrc

COPY ./ros_entrypoint.sh /

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

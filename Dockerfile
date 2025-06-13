#		BSD 3-Clause License
#	
#		Copyright (c) 2023, gem5-X
#	
#		Redistribution and use in source and binary forms, with or without
#		modification, are permitted provided that the following conditions are met:
#	
#		1. Redistributions of source code must retain the above copyright notice, this
#		   list of conditions and the following disclaimer.
#	
#		2. Redistributions in binary form must reproduce the above copyright notice,
#		   this list of conditions and the following disclaimer in the documentation
#		   and/or other materials provided with the distribution.
#	
#		3. Neither the name of the copyright holder nor the names of its
#		   contributors may be used to endorse or promote products derived from
#		   this software without specific prior written permission.
#	
#		THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#		AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#		IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#		DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
#		FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#		DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
#		SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#		CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
#		OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#		OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#		Taken from the gem5-x/TiC-SAT technical manual 

FROM ubuntu:20.04

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

RUN echo "deb http://dk.archive.ubuntu.com/ubuntu/ xenial main" \
	>> /etc/apt/sources.list \
	&& echo \
	"deb http://dk.archive.ubuntu.com/ubuntu/ xenial universe" \
	>> /etc/apt/sources.list \
	&& apt -y update \
	&& apt install -y wget \
	&& wget \
	https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
	&& bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/miniconda3

RUN source /opt/miniconda3/bin/activate \
	&& conda init \
	&& conda create --name py275 -c free python=2.7.5 -y \
	&& conda activate py275 \
	&& conda install scons=3.0.0=py27h8a56064_0 -y

RUN apt-get -y install \
	build-essential \
	gcc-arm-linux-gnueabihf \
	gcc-aarch64-linux-gnu \
	device-tree-compiler \
	make \
	git \
	m4 \
	zlib1g \
	zlib1g-dev \
	libprotobuf-dev \
	protobuf-compiler \
	libprotoc-dev \
	libgoogle-perftools-dev \
	python-dev \
	libboost-all-dev \
	swig=3.0.8-0ubuntu3 \
	&& apt-get -y install diod \
	&& apt-get -y install qemu qemu-user qemu-system qemu-user-static

WORKDIR /home
RUN git clone https://github.com/Gedeon23/ALPINE.git

WORKDIR /home/ALPINE
ADD full_system_images.tar.gz ./
RUN mkdir OUTPUT
RUN mkdir SHARED

WORKDIR /home/ALPINE/gem5-X-ALPINE
ENV M5_PATH=/home/ALPINE/full_system_images
RUN source /opt/miniconda3/bin/activate \
	&& conda activate py275 \
	&& make -C system/arm/dt \
	&& scons build/ARM/gem5.fast

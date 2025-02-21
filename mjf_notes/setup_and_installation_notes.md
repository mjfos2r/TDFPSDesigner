# Installation and setup of TDFPS for custom barcode design

So nanopore sent us the NBD24 kit instead of the 96 barcode kit. This creates a fair amount of issues as now we have to design custom barcodes to fully utilize the
capabilities of our instrument. This should be fairly straightforward. There's even a tool published: [TDFPS](https://github.com/junhaiqi/TDFPSDesigner) that was [published to genome biology](https://doi.org/10.1186/s13059-024-03423-3)

We're gonna clone it, fork it, and update everything to work with my fork.

```bash
gh repo fork junhaiqi/TDFPSDesigner --clone=true
# add the remote (IF CLONED BEFORE FORK)
git remote add fork git@github.com/mjfos2r/TDFPSDesigner.git
# cool now let's see what remotes we have
git remote -v
# Returns:
fork git@github.com:mjfos2r/TDFPSDesigner.git (fetch)
fork git@github.com:mjfos2r/TDFPSDesigner.git (push)
origin git@github.com:junhaiqi/TDFPSDesigner.git (fetch)
origin git@github.com:junhaiqi/TDFPSDesigner.git (push)
#
# we gotta rename fork to origin and origin to upstream.
git remote rename origin upstream
git remote rename fork origin
# Check again to make sure the changes stuck:
git remote -v
# returns:
origin git@github.com:mjfos2r/TDFPSDesigner.git (fetch)
origin git@github.com:mjfos2r/TDFPSDesigner.git (push)
upstream git@github.com:junhaiqi/TDFPSDesigner.git (fetch)
upstream git@github.com:junhaiqi/TDFPSDesigner.git (push)
# groovy
```

---

So I need to install this via conda. I don't want to use conda but I have to. I will fork this and create a docker container but until then, I will install as instructed.

Though I will not be using the chinese mirrors of anaconda. I'll use the domestic mirrors. This is probably best practice?

## Fixing TDFPS_Designer.yaml to *not* use chinese mirrors

Nothing against China but I think it's legitimately against the law to use them on the systems this will be run on? Using domestic anaconda mirrors just to be safe.

This was done manually to change:

```yaml
channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/
```

to:

```yaml
channels:
  - conda-forge
  - defaults
  - pytorch
```

And installed via:

```bash
conda env create -f TDFPS_Designer.yaml
```

> Update after failing to install slow5lib below:
> We also need to install cmake via conda to install slow5lib's python wrapper.
> I'll add that to the env.yaml file above for future installation.
> Update: We also need to install matplotlib for some reason it's not in here??

Which worked!

I also adapted the installation instructions from the repo to simplify installation of additional packages. I merely put them into a `requirements.txt` file and installed that with pip within the environment we just made.

```bash
# activate env
conda activate TDFPS

# create requirements.txt using a heredoc
cat << EOF > requirements.txt
edlib
ont-fast5-api
pod5
EOF

# install the reqs
pip install -r requirements.txt
```

Now to actually install [slow5lib](https://github.com/hasindu2008/slow5lib) which is an unbuilt dep within this tool.
This requires `zlib1g-dev` and `libzstd-dev` so make sure that's installed.

```bash
sudo apt-get update
sudo apt-get install zlib1g-dev libzstd-dev
```

We also need to make sure that we actually cloned *WITH* submodules.

I did not the first time as this VM is fresh/config isn't set.

Simple enough, just use the following: `git submodule update --init --recursive`

**BUT** that only works if the submodule is linked (which this one is not)

BUT it's already tracked in the index despite not having a URL set.
So we gotta rm from the index: `git rm --cached slow5lib`

and link it using: `git submodule add https://github.com/hasindu2008/slow5lib.git slow5lib`

And now we can actually continue...

>ATTENTION:
>We need to use cmake via conda. This is added to the docs above.
>The below now successfully compiles and installs

```bash
# go to the subdir
cd TDFPSDesigner/slow5lib
# compile via make
cmake .
# install using local pip
python3 -m pip install .
```

Okay great, that worked successfully. Now we can continue along with the TDFPS documentation!

---

## ~~Testing out barcode design using kmer mode~~ Fixing installation and final config steps

Lets see if we have everything we need to generate some barcodes.
It may require simulating signal and passing that into this. I'm not sure at this point but we're gonna try to get a usage statement first things first.

```bash
    python selectBarcodeSeq.py
```

***

Okay, so matplotlib is also not installed. Neither is scikit-learn.

Adding both of those to requirements.txt for pip installation.

***

Okay! Now that all dependencies have been managed, we get a proper usage statement!!

```bash
python selectBarcodeSeq.py
usage: This script attempts to solve the barcode design problem in nanopore multi-sample sequencing.
       [-h] --length LENGTH --qsize QSIZE --outdir OUTDIR [--seed SEED]
       [--threshold THRESHOLD] [--thread-num THREAD_NUM] --mode {kmer,fasta}
       [--fasta FASTA]
       [--kit {dna-r9-min,dna-r9-prom,dna-r10-min,dna-r10-prom}]
       [--adapter-seq ADAPTER_SEQ] [--top-flank-seq TOP_FLANK_SEQ]
       [--bottom-flank-seq BOTTOM_FLANK_SEQ]
       [--training-num-each-barcode TRAINING_NUM_EACH_BARCODE]
       [--training-precison-cutoff TRAINING_PRECISON_CUTOFF]
       [--training-recall-cutoff TRAINING_RECALL_CUTOFF]
       [--training-f1Score-cutoff TRAINING_F1SCORE_CUTOFF] [--bio-criteria]
This script attempts to solve the barcode design problem in nanopore multi-sample sequencing.: error: the following arguments are required: --length, --qsize, --outdir, --mode
```

***

Let's test the installation and see what we get!

```bash
>python3.7 selectBarcodeSeq.py --length 10 \
        --qsize 10000 \
        --outdir test_kmer_mjf \
        --threshold 10 \
        --thread-num 8 \
        --mode kmer \
        --seed 15 \
        --training-precison-cutoff 0.95 \
        --kit dna-r10-min
######Initial selection######
######End selection! Total time: 0.124424s######


######10000 noise nanopore signals are being generated######
sh: 1: ./bin/squigulator: Permission denied
######10000 noise nanopore signals are generated! Total time: 2.353767s######


######Final selection######
sh: 1: ./bin/FpsCudaDTWThreshold: Permission denied
Traceback (most recent call last):
  File "selectBarcodeSeq.py", line 602, in <module>
    main()
  File "selectBarcodeSeq.py", line 594, in main
    filter2 = args.bio_criteria, kit = args.kit)
  File "selectBarcodeSeq.py", line 211, in byFPSCudaDTWFinalSelection
    with open(slectedInfoFile, 'r') as sif:
FileNotFoundError: [Errno 2] No such file or directory: 'test_kmer_mjf/TDFPS.info'
```

Wonderful. So I also need to install squigulator. This is available as a precompiled binary but in the spirit of maximum difficulty (and reproducibility) let's just add it as a submodule and compile as we did slow5lib

```bash
git submodule add https://github.com/hasindu2008/squigulator.git squigulator
cd squigulator
make
# now symlink this into conda's path.
#ln -s $(readlink -f squigulator) $CONDA_PREFIX/bin/squigulator
# Actually we don't need to do that at all.
# we need to just copy it into the bin directory within the repo.
cd ..
cp squigulator/squigulator bin/
# and we need to make sure all of those binaries have execution perms.
chmod u+x bin/*
```

***

Okay it absolutely needs a GPU to function.

Time to get all of this into a docker container!

## Dockerize me captain

Okay, so since we need to use a GPU, we might as well throw this into a docker container so that:

1. we don't have to fight these compilers again on a different machine (with gpu)
2. we can just move this over to a new machine ezpz, I'm thinking we should make use of the A800 we have in-house.

Okay, let's throw together our Dockerfile.
We will use ~~debian:bookworm-slim~~ nvidia/cuda:12.3.1-base-debian12

We need to make sure all of the deps are installed by apt.
I also want to not use conda for this so that will be fun.

anyway, switching to Dockerfile now.

UPDATE: ok that's done and it's building right.

## Let's try to get this functional

Using [this repo](https://github.com/JustLeeee/ONT-sequencing-data-library-preparation-pipeline) to figure out how to prep input sequences for barcode generation. Update: We may not need to do any of that at all. Just run it in kmer mode and let'er'rip.

Ok so the docker container builds successfully.

We are gonna run it in kmer mode and also feed it the adapter sequences and flanking region sequences AND the native barcodes!

Native Adapter:
Top strand: 5'-TTTTTTTT CCTGTACTTCGTTCAGTACGTATTGCT-3'
Bottom strand: 5'-ACGTAACTGAACGAAGTACAGG-3'

The command that I will be using to generate these barcodes will be:

>going to search in a kmer space of 10milly with the seed of 318 (represent)

### Command

>>UPDATE: WE NEED TO SPECIFY `--gpus all` in the docker cmd.

```bash
docker run -v $(pwd)/tdfps_output:/data --rm -it mjfos2r/tdfps-designer
# in container:
python3.7 selectBarcodeSeq.py --length 20 \
    --qsize 10000000 \
    --outdir /data/20bp_q100M_t10_pco95_r10prom \
    --threshold 10 \
    --thread-num 18 \
    --mode kmer \
    --seed 318 \
    --training-precison-cutoff 0.95 \
    --kit dna-r10-prom
```

Update: GLIBC for 20.04 is *.31 and squigulator needs*.34-35 so looks like we're building the container on the cuda ubuntu 22.04 image

Update: Apparently the sequencer CUDA is way out of date. I don't want to mess with the drivers on the sequencer so I'm downgrading the image to `cuda:12.4.0-base-ubuntu22.04`
Joy.

gfdi, still getting this error.

```bash
######Start Iteration######
###Current Data Volume: 9999###
CUDA error: CUDA driver version is insufficient for CUDA runtime version : FpsCudaDTWThreshold.cu, line 693
Traceback (most recent call last):
  File "selectBarcodeSeq.py", line 602, in <module>
    main()
  File "selectBarcodeSeq.py", line 594, in main
    filter2 = args.bio_criteria, kit = args.kit)
  File "selectBarcodeSeq.py", line 211, in byFPSCudaDTWFinalSelection
    with open(slectedInfoFile, 'r') as sif:
FileNotFoundError: [Errno 2] No such file or directory: 'test_select_kmer/TDFPS.info
```

This is a problem stemming from the fact that all of the cuda C is pre-compiled.

[resource for debugging](https://arnon.dk/matching-sm-architectures-arch-and-gencode-for-various-nvidia-cards/)

great.

```bash
root@3b6429e6e0fe:/opt/TDFPS# cuobjdump bin/FpsCudaDTWThreshold

Fatbin elf code:
================
arch = sm_52
code version = [1,7]
host = linux
compile_size = 64bit

Fatbin elf code:
================
arch = sm_52
code version = [1,7]
host = linux
compile_size = 64bit

Fatbin ptx code:
================
arch = sm_52
code version = [7,0]
host = linux
compile_size = 64bit
compressed
```

So this is unable to be resolved quickly.
Just need to wait for the programmers in China to get back to me.

Hoorah. I'm going home.

***

# >>{MJF - 2025-02-21 - 11:45:30}<< #

Code authors responded to my git issue and uploaded the cuda source! Now I can compile for my specific version of cuda runtime! Hoorah!

To be safe, let's check on the sequencer's cuda versions so that we can absolutely be sure that it's lining up with the container. (or the inverse rather)

```{bash}
nvidia-smi
# returns:
NVIDIA-SMI 550.54.14
Driver Version: 550.54.14
CUDA Version: 12.4
```

Cool, Fairly certain I've already downgraded the base image to 12.4. Let's make sure tho.

Okay so actually I don't need to do anything aside from make sure the sequencer has the nvidia-container-toolkit installed and it should handle drivers all by itself..

***

## Okay the sequencer needs to be prepped for running GPU containers

Lets install the `nvidia-container-toolkit` package so that docker's runtime can utilize GPU.

[nvidia documentation](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/index.html)

1. configure nvidia's apt repository:

  ```{bash}
  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
    && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
      sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
      sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
  ```

2. Update apt's package list and install the toolkit

  ```{bash}
  sudo apt-get update
  sudo apt-get install -y nvidia-container-toolkit
  ```

3. Configure container runtime using `nvidia-ctk`

  ```{bash}
  sudo nvidia-ctk runtime configure --runtime=docker
  sudo systemctl restart docker
  ```

4. Test that it's working correctly

  ```{bash}
  # spawn a simple container to validate that containers can use the gpu (if we tell them to)
  sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
  # which returns
  Unable to find image 'ubuntu:latest' locally
  latest: Pulling from library/ubuntu
  5a7813e071bf: Pull complete
  Digest: sha256:72297848456d5d37d1262630108ab308d3e9ec7ed1c3286a32fe09856619a782
  Status: Downloaded newer image for ubuntu:latest
  Fri Feb 21 17:30:19 2025
  +-----------------------------------------------------------------------------------------+
  | NVIDIA-SMI 550.54.14              Driver Version: 550.54.14      CUDA Version: 12.4     |
  |-----------------------------------------+------------------------+----------------------+
  | GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
  | Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
  |                                         |                        |               MIG M. |
  |=========================================+========================+======================|
  |   0  NVIDIA A800 80GB PCIe          Off |   00000000:01:00.0 Off |                    0 |
  | N/A   33C    P0             60W /  300W |     771MiB /  81920MiB |      0%      Default |
  |                                         |                        |             Disabled |
  +-----------------------------------------+------------------------+----------------------+

  +-----------------------------------------------------------------------------------------+
  | Processes:                                                                              |
  |  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
  |        ID   ID                                                               Usage      |
  |=========================================================================================|
  +-----------------------------------------------------------------------------------------+
  ```

***

Okay groovy. Now let's expand the dockerfile so that we can compile the cuda C (during container build) using the proper cuda runtime.

[Resource on compilation flags](https://arnon.dk/matching-sm-architectures-arch-and-gencode-for-various-nvidia-cards/)
[Nvidia documentation on compiler flags](https://docs.nvidia.com/cuda/ampere-compatibility-guide/#about-this-document)

The GPU that we have is an `A800 80GB` which is named: `GA100`

per the first resource above, that means we need to use `-arch=sm_86 -gencode=arch=compute_86,code=SM_86`
I'm adding this to the compilation commands provided by the original authors.

Great. Container is being built as I type. Will push to dockerhub and test on Prom ASAP. Till then I'm grabbing lunch.

Update: Container build went off without any errors! now to push to dockerhub and test on the prom.
Will powercycle prom to make sure everything is good to go.

***

## Let's test it out now

Using our commands from earlier: let's make sure to update the command to use gpu with docker and use the nvidia runtime!

We'll use 1M as the size of our kmer space to begin with, just to test that everything is working properly.

```bash
docker run --rm \
  --runtime=nvidia \
  --gpus all \
  -v $(pwd)/tdfps_output:/data \
  -it mjfos2r/tdfps-designer
# in container:
python3.7 selectBarcodeSeq.py --length 20 \
    --qsize 1000000 \
    --outdir /data/20bp_q100M_t10_pco95_r10prom \
    --threshold 10 \
    --thread-num 18 \
    --mode kmer \
    --seed 318 \
    --training-precison-cutoff 0.95 \
    --kit dna-r10-prom
```


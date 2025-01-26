# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=5.5

inherit cmake llvm rocm

LLVM_MAX_SLOT=19

EGIT_REPO_URI="https://github.com/ggerganov/llama.cpp.git"
inherit git-r3

DESCRIPTION="Port of Facebook's LLaMA model in C/C++"
HOMEPAGE="https://github.com/ggerganov/llama.cpp"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="blas cuda lto tests tools rocm"
CPU_FLAGS_X86=( avx avx2 f16c )

DEPEND="blas? ( sci-libs/openblas:= )
	cuda? ( dev-util/nvidia-cuda-toolkit )
	rocm? ( sci-libs/rocBLAS )"
RDEPEND="${DEPEND}"
BDEPEND="${DEPEND}"

S="${WORKDIR}/${P}"

src_configure() {
	if use rocm ; then
		CC=/usr/lib/llvm/${LLVM_MAX_SLOT}/bin/clang
		CXX=/usr/lib/llvm/${LLVM_MAX_SLOT}/bin/clang++
		export DEVICE_LIB_PATH=/usr/lib/amdgcn/bitcode
		export HIP_DEVICE_LIB_PATH=/usr/lib/amdgcn/bitcode
	fi
	local mycmakeargs=(
		-DLLAMA_BLAS="$(usex blas)"
		-DGGML_CUDA="$(usex cuda)"
		-DLLAMA_LTO="$(usex lto)"
		-DLLAMA_BUILD_TESTS="$(usex tests)"
		-DLLAMA_HIPBLAS="$(usex rocm)"
		-DAMDGPU_TARGETS="$(get_amdgpu_flags)"
		-DLLAMA_BUILD_SERVER=OFF
		-DCMAKE_SKIP_BUILD_RPATH=ON
		-DBUILD_NUMBER="1"
	)
	if use cuda ; then
		addpredict /dev/nvidiactl
	fi
	cmake_src_configure
}

src_install() {
	doheader include/llama.h

	cd "${BUILD_DIR}" || die

	dolib.so bin/libggml-base.so
	dolib.so bin/libggml-cpu.so
	dolib.so bin/libggml.so
	dolib.so bin/libllama.so
	dolib.so bin/libllava_shared.so

	if use tools ; then
		dolib.so bin/libggml-cuda.so
	fi

	dobin bin/llama-cli

	if use tools ; then
		dobin bin/llama-batched
		dobin bin/llama-batched-bench
		dobin bin/llama-bench
		dobin bin/llama-convert-llama2c-to-ggml
		dobin bin/llama-cvector-generator
		dobin bin/llama-embedding
		dobin bin/llama-eval-callback
		dobin bin/llama-export-lora
		dobin bin/llama-gbnf-validator
		dobin bin/llama-gen-docs
		dobin bin/llama-gguf
		dobin bin/llama-gguf-hash
		dobin bin/llama-gguf-split
		dobin bin/llama-gritlm
		dobin bin/llama-imatrix
		dobin bin/llama-infill
		dobin bin/llama-llava-cli
		dobin bin/llama-lookahead
		dobin bin/llama-lookup
		dobin bin/llama-lookup-create
		dobin bin/llama-lookup-merge
		dobin bin/llama-lookup-stats
		dobin bin/llama-minicpmv-cli
		dobin bin/llama-parallel
		dobin bin/llama-passkey
		dobin bin/llama-perplexity
		dobin bin/llama-q8dot
		dobin bin/llama-quantize
		dobin bin/llama-quantize-stats
		dobin bin/llama-qwen2vl-cli
		dobin bin/llama-retrieval
		dobin bin/llama-run
		dobin bin/llama-save-load-state
		dobin bin/llama-simple
		dobin bin/llama-simple-chat
		dobin bin/llama-speculative
		dobin bin/llama-speculative-simple
		dobin bin/llama-tokenize
		dobin bin/llama-tts
		dobin bin/llama-vdot
	fi
}

pkg_postinst() {
	elog "The main binary has been installed as \"llama-cpp\""
}

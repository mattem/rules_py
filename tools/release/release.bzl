"Make releases for platforms supported by rules_py"

load("@aspect_bazel_lib//lib:transitions.bzl", "platform_transition_filegroup")
load("@aspect_bazel_lib//lib:copy_file.bzl", "copy_file")
load("@aspect_bazel_lib//tools/release:hashes.bzl", "hashes")

# buildozer: disable=function-docstring
def multi_arch_release(name, bins, os, cpus = ["aarch64", "x86_64"]):
    artifacts = []
    for bin in bins:
        for cpu in cpus:
            platform_transition_filegroup(
                name = "{}_{}_{}_build".format(bin, os, cpu),
                srcs = ["//py/tools/{}_bin".format(bin)],
                target_platform = "{}_{}".format(os, cpu),
                target_compatible_with = ["@platforms//os:{}".format(os)],
            )

            artifact = "{}-{}-{}".format(bin, os, cpu)
            artifacts.append(artifact)
            copy_file(
                name = "copy_{}_{}_{}".format(bin, os, cpu),
                src = "{}_{}_{}_build".format(bin, os, cpu),
                out = artifact,
                target_compatible_with = ["@platforms//os:{}".format(os)],
            )

            hash_file = "{}_{}_{}.sha256".format(bin, os, cpu)
            artifacts.append(hash_file)
            hashes(
                name = hash_file,
                src = artifact,
                target_compatible_with = ["@platforms//os:{}".format(os)],
            )

    native.filegroup(
        name = name,
        srcs = artifacts,
        target_compatible_with = ["@platforms//os:{}".format(os)],
        tags = ["manual"],
    )

    return artifacts

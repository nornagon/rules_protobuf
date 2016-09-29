load("//protobuf:rules.bzl",
     "proto_compile",
     "proto_language",
     "proto_language_deps",
     "proto_repositories")

def java_proto_repositories(lang_requires = [
    "com_google_protobuf_protobuf_java",
    "com_google_protobuf_protobuf_java_util",
    "com_google_code_gson_gson",
    "com_google_guava_guava",
    "junit_junit_4", # TODO: separate test requirements
    "com_google_code_findbugs_jsr305",

    "protoc_gen_grpc_java_linux_x86_64",
    "protoc_gen_grpc_java_macosx",

    "io_grpc_grpc_core",
    "io_grpc_grpc_context",
    "io_grpc_grpc_stub",
    "io_grpc_grpc_protobuf",
    "io_grpc_grpc_protobuf_lite",

    # "com_squareup_okhttp_okhttp",
    # "com_squareup_okio_okio",
    # "io_grpc_grpc_auth",
    # "io_grpc_grpc_netty",
    # "io_grpc_grpc_okhttp",
    # "io_grpc_grpc_protobuf_lite",
    # "io_netty_netty_buffer",
    # "io_netty_netty_codec",
    # "io_netty_netty_codec_http",
    # "io_netty_netty_codec_http2",
    # "io_netty_netty_common",
    # "io_netty_netty_handler",
    # "io_netty_netty_resolver",
    # "io_netty_netty_transport",
    # "com_google_auth_google_auth_library_credentials",
  ], **kwargs):
  proto_repositories(lang_requires = lang_requires, **kwargs)

def nano_proto_repositories(
    lang_requires = [
      "com_google_protobuf_nano_protobuf_javanano",
      "io_grpc_grpc_protobuf_nano",
    ], **kwargs):
  proto_repositories(lang_requires = lang_requires, **kwargs)


def java_proto_compile(langs = [str(Label("//java"))], **kwargs):
  proto_compile(langs = langs, **kwargs)

def java_proto_library(
    name,
    langs = [str(Label("//java"))],
    protos = [],
    imports = [],
    inputs = [],
    output_to_workspace = False,
    proto_deps = [],
    protoc = None,

    pb_plugin = None,
    pb_options = [],

    grpc_plugin = None,
    grpc_options = [],

    proto_compile_args = {},
    with_grpc = True,
    srcs = [],
    deps = [],
    verbose = 0,
    **kwargs):

  proto_compile_args += {
    "name": name + ".pb",
    "protos": protos,
    "deps": [dep + ".pb" for dep in proto_deps],
    "langs": langs,
    "imports": imports,
    "inputs": inputs,
    "pb_options": pb_options,
    "grpc_options": grpc_options,
    "output_to_workspace": output_to_workspace,
    "verbose": verbose,
  }

  if protoc:
    proto_compile_args["protoc"] = protoc
  if pb_plugin:
    proto_compile_args["pb_plugin"] = pb_plugin
  if grpc_plugin:
    proto_compile_args["grpc_plugin"] = grpc_plugin

  proto_compile(**proto_compile_args)

  proto_language_deps(
    name = name + "_compile_deps",
    langs = langs,
    file_extensions = [".jar"],
    with_grpc = with_grpc,
  )

  native.java_import(
    name = name + "_compile_imports",
    jars = [name + "_compile_deps"],
  )

  native.java_library(
    name = name,
    srcs = srcs + [name + ".pb"],
    deps = list(set(deps + proto_deps + [name + "_compile_imports"])),
    **kwargs)


def java_proto_language_import(name,
                               langs = [str(Label("//java"))],
                               with_grpc = True,
                               **kwargs):
  proto_language_deps(
    name = name + ".deps",
    langs = langs,
    file_extensions = [".jar"],
    with_grpc = with_grpc,
    **kwargs
  )

  native.java_import(
    name = name,
    jars = [name + ".deps"],
  )

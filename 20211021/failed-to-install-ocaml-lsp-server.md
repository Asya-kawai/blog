# Failed to install ocaml-lsp-server in OCaml 4.12.0

When tried to install ocaml-lsp-server, I encountered an error as below.

Then I used OCaml 4.12.0.

```
% opam install ocaml-lsp-server
[NOTE] It seems you have not updated your repositories for a while. Consider updating them with:
       opam update


<><> Synchronising pinned packages ><><><><><><><><><><><><><><><><><><><><><><>
[ocaml-lsp-server.1.4.1] no changes from git+https://github.com/ocaml/ocaml-lsp.git

The following actions will be performed:
  ∗ install ocaml-lsp-server 1.4.1*
[ocaml-lsp-server.1.4.1] synchronised from git+https://github.com/ocaml/ocaml-lsp.git

<><> Processing actions <><><><><><><><><><><><><><><><><><><><><><><><><><><><>
[ERROR] The compilation of ocaml-lsp-server failed at "/home/toshiki/.opam/opam-init/hooks/sandbox.sh build dune build -j 7 ocaml-lsp-server.install
        --release".

#=== ERROR while compiling ocaml-lsp-server.1.4.1 =============================#
# context     2.0.8 | linux/x86_64 | ocaml-base-compiler.4.12.0 | pinned(git+https://github.com/ocaml/ocaml-lsp.git#fd1d291f)
# path        ~/.opam/local/.opam-switch/build/ocaml-lsp-server.1.4.1
# command     ~/.opam/opam-init/hooks/sandbox.sh build dune build -j 7 ocaml-lsp-server.install --release
# exit-code   1
# env-file    ~/.opam/log/ocaml-lsp-server-4188664-48c407.env
# output-file ~/.opam/log/ocaml-lsp-server-4188664-48c407.out
### output ###
# File "ocaml-lsp-server/src/dune", line 33, characters 2-21:
# 33 |   ocamlformat-rpc-lib
#        ^^^^^^^^^^^^^^^^^^^
# Error: Library "ocamlformat-rpc-lib" not found.
# Hint: try:
#   dune external-lib-deps --missing --no-config --root . --ignore-promoted-rules --default-target @install --always-show-command-line --promote-install-files --release --profile release -j 7 ocaml-lsp-server.install



<><> Error report <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
┌─ The following actions failed
│ λ build ocaml-lsp-server 1.4.1
└─
╶─ No changes have been performed
```

So I installed ocamlformat-rpc-lib before install ocaml-lsp-server. 

```
% opam install ocamlformat-rpc-lib
[NOTE] It seems you have not updated your repositories for a while. Consider updating them with:
       opam update

The following actions will be performed:
  ∗ install ocamlformat-rpc-lib 0.18.0

<><> Gathering sources ><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
[ocamlformat-rpc-lib.0.18.0] found in cache

<><> Processing actions <><><><><><><><><><><><><><><><><><><><><><><><><><><><>
∗ installed ocamlformat-rpc-lib.0.18.0
Done.
```

Finally, I have successfully installed ocaml-lsp-server!

```
% opam install ocaml-lsp-server
[NOTE] It seems you have not updated your repositories for a while. Consider updating them with:
       opam update


<><> Synchronising pinned packages ><><><><><><><><><><><><><><><><><><><><><><>
[ocaml-lsp-server.1.4.1] no changes from git+https://github.com/ocaml/ocaml-lsp.git

The following actions will be performed:
  ∗ install ocaml-lsp-server 1.4.1*
[ocaml-lsp-server.1.4.1] synchronised from git+https://github.com/ocaml/ocaml-lsp.git

<><> Processing actions <><><><><><><><><><><><><><><><><><><><><><><><><><><><>
∗ installed ocaml-lsp-server.1.4.1
Done.

opam list | grep lsp-server
ocaml-lsp-server        1.4.1              pinned to version 1.4.1 at git+https://github.com/ocaml/ocaml-lsp.git
```

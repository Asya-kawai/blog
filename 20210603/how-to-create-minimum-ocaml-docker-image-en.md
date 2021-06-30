# How to make the smallest OCaml Docker container image

OCaml used to use a build tool called `jbuilder`.

However, since 2018, it has been replaced by a project called `dune`.
This page shows how to build an application with `dune` and create a minimal Docker container image.

See: [dune migration](https://dune.readthedocs.io/en/latest/migration.html?highlight=Jbuilder#migration)

## Install opam

`opam` is a package management tool for OCaml.

You should install it beforehand, because you use it to install OCaml libraries (modules) and tools such as `dune`.

Execute the following command to install `opam`.

Note that the environment to install is `Ubuntu 20.04`.

```
sh <(curl -sL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)
```

Reference: [How to install opam](https://opam.ocaml.org/doc/Install.html)

The next step is the initialization process.

```
opam init
```

When you run `opam init`, you may be prompted for recommended packages as follows.

```
root@90e8251e3431:/# opam init
[WARNING] Running as root is not recommended.
[NOTE] Will configure from built-in defaults.
Checking for available remotes: none.
  - You won't be able to use rsync and local repositories unless you install the rsync command on your system.
  - Checking for available remotes: none. you won't be able to use git repositories unless you install the git command on your system.
  - you won't be able to use mercurial repositories unless you install the hg command on your system. you won't be able to use mercurial repositories unless you install the hg command on your system.
  - You won't be able to use darcs repositories unless you install the darcs command on your system.

[WARNING] Recommended dependencies -- most packages rely on these:
  - make
  - m4
  - [WARNING] Recommended dependencies -- most packages rely on these: make m4 cc
[ERROR] Missing dependencies -- the following commands are required for opam to operate:
  - patch
  - unzip
  - bwrap: Sandboxing tool bwrap was not found. You should install 'bubblewrap'. You should install 'bubblewrap'. See https://opam.ocaml.org/doc/FAQ.html#Why-does-opam-require-bwrap.
```

Follow the instructions above to install the packages.

```
apt install git hg darcs rsync pkg-config make m4 gcc patch unzip bubblewrap
```

After the installation is complete, run `opam init` again.

You may be asked if you want to overwrite the configuration file as follows.
You may be asked to overwrite the configuration file as follows, but if you are using it for the first time, just select `yes`.

```
Do you want opam to modify ~/.profile? [N/y/f]
(default is 'no', use 'f' to choose a different file) y
A hook can be added to opam's init scripts to ensure that the shell remains in sync with the opam environment when they are loaded. Set that up? [y/N] y
```
Note that `opam init` will create a switch called `default`.
Note that `opam init` creates a switch called `default`, which is a mechanism of `opam` to manage the compiler and packages as a single unit.

To enable it, you may be asked to `eval $(opam env)`, so run this command.

### How to use packages each projects

There are various versions of OCaml, and you may want to use several different versions in some cases.

In that case, you can use the command `opam switch` to consolidate the compiler and packages into one group (called a switch).

For example, the following command creates a switch named `my-app` that uses the compiler 4.12.0.

```
opam switch create my-app ocaml-base-compiler.4.12.0
```

You can check the created switch with the `opam switch` command. An example is shown below.

```
opam switch
# switch compiler description
    default ocaml-base-compiler.4.12.0 default
-> my-app ocaml-base-compiler.4.12.0 my-app
```

Reference: [opam switch](https://opam.ocaml.org/doc/man/opam-switch.html)

## Creating an OCaml application

First, install `dune`, a build tool for application development in OCaml.

In addition, since we plan to develop a web application, we will also install the libraries (modules) required for the web application.

```
opam install dune lwt cohttp-lwt-unix
```

In order to use `dune`, you need to use a configuration file named `dune`.

To use `dune`, you need to create a configuration file called `dune`, which contains the name of the executable file and the library to be used.
However, in this case, you need to specify that the binary should be configured with static links, because it is assumed to be used in a Docker container.

Reference: [dune quickstart](https://dune.readthedocs.io/en/stable/quick-start.html)

In this paper, we will generate an application named `main`.

The following is the content of the `dune` file.

```
;; https://discuss.ocaml.org/t/linking-several-so-libraries-produced-by-dune/6133
(executable
 (name main)
 (link_flags :standard -linkall)
 (libraries lwt cohttp-lwt-unix)
)
```

Next, we create the application body.

In this paper, we will create a sample application using the `cohttp` library (module).

We will create a sample application using the `cohttp` library (module).

``` 
open Lwt
open Cohttp
open Cohttp_lwt_unix

let server =
  let callback _conn req body =
    let uri = req |> Request.uri |> Uri.to_string in
    let meth = req |> Request.meth |> Code.string_of_method in
    let headers = req |> Request.headers |> Header.to_string in
    ( body |> Cohttp_lwt.Body.to_string >|= fun body ->
      Printf.sprintf "Uri: %s\nMethod: %s\nHeaders\nHeaders: %s\nBody: %s" uri
        meth headers body )
    >>= fun body -> Server.respond_string ~status:`OK ~body ()
  in
  Server.create ~mode:(`TCP (`Port 8000)) (Server.make ~callback ())

let () = ignore (Lwt_main.run server)
```

See: [cohttp basic server tutorial](https://github.com/mirage/ocaml-cohttp#basic-server-tutorial)

You can check if the binary file works or not by using one of the following commands.

```
dune build main.exe
```

or

```
_build/default/main.exe
```

## Create Dockerfile

The next step is to create a `Dockerfile`.

Docker containers are divided into three stages to support multi-stage builds.

Each stage and its role are shown below.

* init-opam
  * The stage to update the package of the container image shipped with opam.
* ocmal-app-base
  * The stage to install the packages necessary for building the application and to build the application.
* ocaml-app
  * Stage to copy the binary file created by ocaml-app-base into the minimum container image and set the entry point

The contents of the `Dockerfile` for the above stages are shown below.

```
FROM ocaml/opam:alpine AS init-opam

RUN set -x && \
    : "Update and upgrade default packagee" && \
    sudo apk update && sudo apk upgrade && \
    sudo apk add gmp-dev

# --- #

FROM init-opam AS ocaml-app-base
COPY . .
RUN set -x && \
    : "Install related pacakges" && \
    opam install . --deps-only --locked && \
    eval $(opam env) && \
    : "Build applications" && \
    dune build main.exe && \
    sudo cp ./_build/default/main.exe /usr/bin/main.exe

# --- #

FROM alpine AS ocaml-app

COPY --from=ocaml-app-base /usr/bin/main.exe /home/app/main.exe
RUN set -x && \
    : "Create a user to execute application" && \
    adduser -D app && \
    : "Change owner to app" && \
    chown app:app /home/app/main.exe

WORKDIR /home/app
USER app
ENTRYPOINT ["/home/app/main.exe"]
```

This time, we decided to use a lock file to manage the packages that depend on this program.

Create a file `dune-project`, and describe the packages that this program uses in the file.

The contents of `dune-project` are as follows.

```
(lang dune 2.7)
(name main)
(version 1.0.0)

(generate_opam_files true)

(license MIT)
(authors "Toshiki Kawai")
(maintainers "Toshiki Kawai")

(package
  (name main)
  (synopsis "The First architecture on OCaml")
  (description "The First architecture style when startup project.") 
  (depends
    (dune (> 1.5))
    (lwt (>= 5.4.0))
    (cohttp-lwt-unix (>= 4.0.0))
    (yojson (>= 1.7.0))))
```

Put this `Dockerfile`, the `dune` file created in the previous chapter, and `main.ml` in the same directory.

```
Dockerfile dune dune-project main.ml
```

Then, run `docker build .` command to create a Docker container image.

This time, use `docker build --tag 20210530-ocaml-micro-service .` and run it with
This time, we ran `docker build --tag 20210530-ocaml-micro-service .` to tag the Docker container image with the name 20210530-ocaml-micro-service.

The image size after the build is 25MB, which is quite a small container image.

```
docker images
REPOSITORY TAG IMAGE ID CREATED SIZE
20210530-ocaml-micro-service latest 589420cffa3a 3 days ago 25MB
```

## Summary

You can use useful tools such as opam and dune to help you create OCaml applications and develop them efficiently.

But the image size will increase and you will end up installing things that are not necessary for your application if you include tools such as opam and dune in your Docker image.

To solve this problem, we use multi-stage build, and use useful tools such as opam and dune before the build.
In the end, we succeeded in creating a minimal image by deploying only the application on a lightweight OS such as alpine.

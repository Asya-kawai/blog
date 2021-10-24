# How to use draw.io with Emacs

[draw.io](https://drawio-app.com/tutorials/interactive-tutorials/) is a service that makes it easy to create and edit diagrams.

Draw.io is available for browsers and desktop applications,
and there is also a VSCode extension.

On the other hand, there is no extension for draw.io in Emacs yet.
So, here is how to use draw.io in Emacs.

## Displaying draw.io in Emacs

Since it is difficult to create a UI that imitates draw.io from scratch,
I decided to display the browser version of draw.io in Emacs.

In order to draw a browser screen on Emacs, you need to use `webkit`.

If you are using Ubuntu, you can install it as follows.

```
sudo apt update
sudo apt install libwebkit2gtk-4.0-dev
```

If you want to improve the boot speed by [native compilation](https://www.emacswiki.org/emacs/GccEmacs) of Emacs, also install the following package.

```
sudo apt libgccjit-9-dev
``` 

Next, download the Emacs source code from Github.

``` 
git clone https://github.com/emacs-mirror/emacs.git
cd emacs
```

Execute the following commands to build and install Emacs.

`--with-native-compilation` is an option for native compilation, and
`--with-xwidgets` is an option for using webkit.

Note that `--with-mailutils` is added to avoid warnings.

```
./autogen.sh
./configure --with-native-compilation --with-xwidgets --with-mailutils
make clean
make
sudo make install
```

To confirm, run the following command to start Emacs.

The `-q` option is to not read the configuration file.

```
emacs -q
```

You can use draw.io on Emacs by typing `M-x xwidget-webkit-browse-url` and then typing `https://app.diagrams.net/`.

## Launch the browser version of draw.io from Emacs.

Depending on the version of Emacs, webkit, or a combination of the two, it may not work properly.

In that case, we recommend you to start the browser version of draw.io from Emacs.

After typing `M-x browse-url`, you can start the browser version of draw.io from Emacs by typing `https://app.diagrams.net/`.

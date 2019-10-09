# Every example of pattern matching (almost) from the docs

Really, it's a lot of examples from the docs. 

Plus some weird excursions, like Peano arithmetic (see Notebook 2), to illustrate pattern matching in recursion.

NOTE: This requires Python, Jupyter Notebooks, and [IElixir for Jupyter](https://github.com/pprzetacznik/IElixir).

## Docker

### From scratch (takes hours)
* `docker build  -t ielixir_notebook .`
* Use the commands below to run a container.

### From an image (large download)
* This assumes you have Docker installed.
* Pull the image `docker pull mudphone/ielixir_notebook`
* Clone this repo, then `cd` into it
* Run a container
  * `docker run --name my_iex_notebook -it -p 8888:8888 --user jovyan -v "$PWD":/home/jovyan/jupyter-env/patterns mudphone/ielixir_notebook bash`
* Note:
  * the name of the container: `my_iex_notebook` (make it what you wish)
  * the port: 8888 (you'll use this to connect to Jupyter notebooks)
  * the user: jovyan (that's the default Jupyter image user name)
  * the shared volume: `-v host_source:container_target`
* Start the container
  * `docker start my_iex_notebook`
* From the container, launch Jupyter notebook
* `cd ~/jupyter-env`
  * `pipenv shell`
  * `jupyter notebook patterns`
  * Note the URL, you'll use it to connect from the host
* From the host, connect to the notebook
  * Open a browser to `http://127.0.0.1:8888/?token=xxxx`
  * Note: `token=xxxx` must be replaced with whatever you saw from the container when you started the Jupyter notebook

### Also
* Stop the container
  * `docker stop my_iex_notebook`
* Connect to a running container
  * `docker exec -it --user jovyan my_iex_notebook bash`
* Use `--rm` to `rum` a container and delete it after you exit

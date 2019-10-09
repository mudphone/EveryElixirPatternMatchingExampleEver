# Every example of pattern matching (almost) from the docs

Really, it's a lot of examples from the docs. 

Plus some weird excursions, like Peano arithmetic (see Notebook 2), to illustrate pattern matching in recursion.

NOTE: This requires Python, Jupyter Notebooks, and [IElixir for Jupyter](https://github.com/pprzetacznik/IElixir).

## Docker
* `docker build  -t ielixir_notebook .`

* `docker run --name my_iex_notebook -i -t --rm ielixir_notebook`

* `docker run --name my_iex_notebook -it -p 8888:8888 --user jovyan -v "$PWD":/home/jovyan/jupyter-env/patterns mudphone/ielixir_notebook bash`

* `docker start my_iex_notebook`

* `docker exec -it --user jovyan my_iex_notebook bash`
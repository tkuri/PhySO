FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# 一般ユーザーの作成
RUN useradd -m -s /bin/bash myuser

# システムとAnacondaのインストール
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y \
        libgl1-mesa-glx \
        libegl1-mesa \
        libxrandr2 \
        libxrandr2 \
        libxss1 \
        libxcursor1 \
        libxcomposite1 \
        libasound2 \
        libxi6 \
        libxtst6 \
        wget \
        texlive-latex-extra \
        texlive-fonts-recommended \
        texlive-fonts-extra \
        dvipng \
        cm-super && \
    wget -P /opt https://repo.anaconda.com/archive/Anaconda3-2023.03-Linux-x86_64.sh && \
    bash /opt/Anaconda3-2023.03-Linux-x86_64.sh -b -p /opt/anaconda3 && \
    rm /opt/Anaconda3-2023.03-Linux-x86_64.sh && \
    echo "export PATH=/opt/anaconda3/bin:$PATH" > /etc/profile.d/conda.sh && \
    chown -R myuser:myuser /opt/anaconda3

# 一般ユーザーとして実行
USER myuser

# 環境変数を引き継ぐ
ENV PATH="/opt/anaconda3/bin:$PATH"
SHELL ["/bin/bash", "-c"]

# Conda環境の作成とアクティベート
RUN conda create -n PhySO python=3.8 && \
    echo "conda activate PhySO" >> ~/.bashrc

# ワーキングディレクトリを設定し、ローカルファイルをコンテナにコピー
WORKDIR /app
COPY . .

# 現在のディレクトリの所有者を変更
USER root
RUN chown -R myuser:myuser /app
USER myuser

# 依存関係のインストール
RUN conda install --file requirements.txt && \
    conda install --file requirements_display1.txt && \
    pip install -r requirements_display2.txt && \
    pip install --upgrade --no-cache-dir -e .

# Jupyter Notebookのインストール
RUN conda install -c conda-forge jupyterlab

# Jupyter Notebookの設定
RUN jupyter notebook --generate-config && \
    echo "c.NotebookApp.ip = '0.0.0.0'" >> ~/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.allow_root = True" >> ~/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.open_browser = False" >> ~/.jupyter/jupyter_notebook_config.py

# Jupyter Notebookのポートを公開
EXPOSE 8888
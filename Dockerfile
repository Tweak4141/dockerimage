# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: glibc
# Minimum Panel Version: 0.6.0
# ----------------------------------
FROM node:alpine

RUN apk --no-cache upgrade
RUN apk add --no-cache git msttcorefonts-installer python3 alpine-sdk ffmpeg \
    zlib-dev libpng-dev libjpeg-turbo-dev freetype-dev fontconfig-dev \
    libtool libwebp-dev libxml2-dev pango-dev freetype fontconfig \
	vips vips-dev

# liblqr needs to be built manually for magick to work
# and because alpine doesn't have it in their repos
RUN git clone https://github.com/carlobaldassi/liblqr \
		&& cd liblqr \
		&& ./configure \
		&& make \
		&& make install

# install imagemagick from source rather than using the package
# since the alpine package does not include pango support.
RUN git clone https://github.com/ImageMagick/ImageMagick.git ImageMagick \
    && cd ImageMagick \
    && ./configure \
		--prefix=/usr \
		--sysconfdir=/etc \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info \
		--enable-static \
		--disable-openmp \
		--with-threads \
		--with-png \
		--with-webp \
		--with-modules \
		--with-pango \
		--without-hdri \
		--with-lqr \
    && make \
    && make install

RUN update-ms-fonts && fc-cache -f
RUN adduser container -h /home/container -d
USER container
ENV  USER=container HOME=/home/container
WORKDIR /home/container

COPY ./assets/caption.otf /usr/share/fonts/caption.otf
COPY ./assets/caption2.ttf /usr/share/fonts/caption2.ttf
COPY ./assets/hbc.ttf /usr/share/fonts/hbc.ttf
COPY ./assets/reddit.ttf /usr/share/fonts/reddit.ttf
RUN fc-cache -fv

COPY --chown=node:node ./package.json package.json
COPY --chown=node:node ./package-lock.json package-lock.json
RUN npm install
COPY . .
RUN npm run build

COPY ./entrypoint.sh /entrypoint.sh
CMD  ["/bin/bash", "/entrypoint.sh"]

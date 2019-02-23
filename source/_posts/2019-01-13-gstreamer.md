---
title: GStreamer大杂烩
categories:
  - Programming
  - C
tags:
  - Programming
  - C
  - GStreamer
  - Multimedia
  - Tutorial
  - Audio
date: 2019-01-13 18:23:01
---

GStreamer是一个使用C语言编写的多媒体框架，主要用于音视频的播放与编辑

## GStreamer安装

以macOS为例:

`brew install gstreamer gst-libav gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly`

## GStreamer的CMake配置

```CMakeList
cmake_minimum_required(VERSION 3.13)
project(untitled1 C)

set(CMAKE_C_STANDARD 11)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK3 REQUIRED gtk+-3.0)
pkg_check_modules(GST REQUIRED gstreamer-1.0>=1.4)

include_directories(${GTK3_INCLUDE_DIRS})
link_directories(${GTK3_LIBRARY_DIRS})
add_definitions(${GTK3_CFLAGS_OTHER})

include_directories(${GST_INCLUDE_DIRS})
link_directories(${GST_LIBRARY_DIRS})

add_executable(untitled1 main.c)
target_link_libraries(untitled1 ${GTK3_LIBRARIES})
target_link_libraries(untitled1 ${GST_LIBRARIES})
```

<!--more-->

## 用GStreamer播放音乐文件(MP3、WMA与OGG)

GStreamer播放多媒体文件需要指定解码器。WMA与OGG都是容器格式，需要特殊处理 

```c
#include <gst/gst.h>

static gboolean bus_call(GstBus *bus, GstMessage *msg, gpointer data) {
    GMainLoop *loop = (GMainLoop *) data;

    switch (GST_MESSAGE_TYPE (msg)) {

        case GST_MESSAGE_EOS:
            g_print("End of stream\n");
            g_main_loop_quit(loop);
            break;

        case GST_MESSAGE_ERROR: {
            gchar *debug;
            GError *error;

            gst_message_parse_error(msg, &error, &debug);
            g_free(debug);

            g_printerr("Error: %s\n", error->message);
            g_error_free(error);

            g_main_loop_quit(loop);
            break;
        }
        default:
            break;
    }

    return TRUE;
}


static void on_pad_added(GstElement *element, GstPad *pad, gpointer data) {
    GstPad *sinkpad;
    GstElement *decoder = (GstElement *) data;

    g_print("Dynamic pad created, linking demuxer/decoder\n");

    sinkpad = gst_element_get_static_pad(decoder, "sink");

    gst_pad_link(pad, sinkpad);

    gst_object_unref(sinkpad);
}

enum FORMAT {
    MP3, WMA, OGG
};

int main(int argc, char *argv[]) {
    GMainLoop *loop;

    GstElement *pipeline, *source, *demuxer, *decoder, *conv, *sink;
    GstBus *bus;
    guint bus_watch_id;

    gchar *demuxers[] = {"mpegaudioparse", "asfdemux", "oggdemux"};
    gchar *decoders[] = {"avdec_mp3", "avdec_wmav2", "vorbisdec"};

    gst_init(&argc, &argv);

    loop = g_main_loop_new(NULL, FALSE);

    if (argc != 2) {
        g_printerr("Usage: %s <Filename>\n", argv[0]);
        return -1;
    }

    gchar *filename = argv[1];

    enum FORMAT format = MP3;
    if (strstr(filename, ".wma") != NULL) {
        format = WMA;
    } else if (strstr(filename, ".ogg") != NULL) {
        format = OGG;
    }

    gchar *demuxer_name = demuxers[format];
    gchar *decoder_name = decoders[format];

    pipeline = gst_pipeline_new("audio-player");
    source = gst_element_factory_make("filesrc", "file-source");
    demuxer = gst_element_factory_make(demuxer_name, "ogg-demuxer");
    decoder = gst_element_factory_make(decoder_name, "vorbis-decoder");
    conv = gst_element_factory_make("audioconvert", "converter");
    sink = gst_element_factory_make("autoaudiosink", "audio-output");

    if (!pipeline || !source || !demuxer || !decoder || !conv || !sink) {
        g_printerr("One element could not be created. Exiting.\n");
        return -1;
    }

    g_object_set(G_OBJECT (source), "location", filename, NULL);

    bus = gst_pipeline_get_bus(GST_PIPELINE (pipeline));
    bus_watch_id = gst_bus_add_watch(bus, bus_call, loop);
    gst_object_unref(bus);

    gst_bin_add_many(GST_BIN (pipeline), source, demuxer, decoder, conv, sink, NULL);

    if (format == MP3) {
        gst_element_link_many(source, demuxer, decoder, conv, sink, NULL);
    } else {
        gst_element_link(source, demuxer);
        gst_element_link_many(decoder, conv, sink, NULL);
        g_signal_connect (demuxer, "pad-added", G_CALLBACK(on_pad_added), decoder);
    }

    g_print("Now playing: %s\n", filename);
    gst_element_set_state(pipeline, GST_STATE_PLAYING);

    g_print("Running...\n");
    g_main_loop_run(loop);

    g_print("Returned, stopping playback\n");
    gst_element_set_state(pipeline, GST_STATE_NULL);

    g_print("Deleting pipeline\n");
    gst_object_unref(GST_OBJECT (pipeline));
    g_source_remove(bus_watch_id);
    g_main_loop_unref(loop);

    return 0;
}

```

## GStreamer直接播放媒体文件(PlayBin)

```c
#include <gst/gst.h>

static void refresh_progress(GstElement *element) {
    gint64 position;
    gst_element_query_position(element, GST_FORMAT_TIME, &position);
    g_print("Position: %.2f seconds\n", position * 1.0 / GST_SECOND);
}

int main(int argc, char *argv[]) {
    GMainLoop *loop = g_main_loop_new(NULL, FALSE);
    gst_init(&argc, &argv);
    GstElement *playbin = gst_element_factory_make("playbin", NULL);
    g_assert(playbin);
    g_object_set(playbin, "uri", "file:///Users/bj/tmp/juan.wma", NULL);
    gst_element_set_state(playbin, GST_STATE_PLAYING);
    g_timeout_add_seconds(1, (GSourceFunc) refresh_progress, playbin);
    g_main_loop_run(loop);
}
```

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)

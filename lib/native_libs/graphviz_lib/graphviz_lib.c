#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <graphviz/cgraph.h>
#include <graphviz/gvc.h>

struct GraphImage {
    unsigned char *data;
    size_t length;
};

typedef struct GraphImage GraphImage;

#ifdef __cplusplus
extern "C" {
#endif

GraphImage generate_graph(const char *dot_input) {
    GraphImage img = {NULL, 0};

    GVC_t *gvc = gvContext();
    if (!gvc) return img;

    Agraph_t *graph = agmemread(dot_input);
    if (!graph) {
        gvFreeContext(gvc);
        return img;
    }

    if (gvLayout(gvc, graph, "dot") != 0) {
        agclose(graph);
        gvFreeContext(gvc);
        return img;
    }

    char *data;
    unsigned int length;
    if (gvRenderData(gvc, graph, "png", &data, &length) != 0) {
        gvFreeLayout(gvc, graph);
        agclose(graph);
        gvFreeContext(gvc);
        return img;
    }

    img.data = (unsigned char *)malloc(length);
    if (!img.data) {
        gvFreeRenderData(data);
        gvFreeLayout(gvc, graph);
        agclose(graph);
        gvFreeContext(gvc);
        return img;
    }

    memcpy(img.data, data, length);
    img.length = length;

    gvFreeRenderData(data);
    gvFreeLayout(gvc, graph);
    agclose(graph);
    gvFreeContext(gvc);

    return img;
}

void free_graph_image(GraphImage img) {
    free(img.data);
}


#ifdef __cplusplus
}
#endif
//gcc ./graphviz_lib.c -lgvc -lcgraph -lcdt -o gv.out

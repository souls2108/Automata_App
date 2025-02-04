#ifndef GRAPHVIZ_LIB_CPP_H
#define GRAPHVIZ_LIB_CPP_H

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    unsigned char *data;
    unsigned int length;
} GraphImage;

GraphImage generate_graph(const char *dot_input);

void free_graph_image(GraphImage img);

#ifdef __cplusplus
}
#endif

#endif

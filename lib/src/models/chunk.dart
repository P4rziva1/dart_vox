class Chunk {
  final String chunkId;
  final int contentSize;
  final int childrenSize;
  final String content;
  int chunkSize = 0;

  Chunk(this.chunkId, this.contentSize, this.childrenSize, this.content);
}
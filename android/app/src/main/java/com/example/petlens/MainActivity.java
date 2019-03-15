package com.example.petlens;

import java.io.IOException;
import java.util.List;
import android.os.Bundle;
import android.content.ContextWrapper;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.util.PathUtils;

import com.spotify.annoy.ANNIndex;
import com.spotify.annoy.IndexType;

public class MainActivity extends FlutterActivity {

  private static final String CHANNEL = "com.petlens/model";
  // ContextWrapper c = new ContextWrapper(this);
  private static ANNIndex index;

  private void loadEmbeddings(String path, Result result){
    // ContextWrapper c = new ContextWrapper(this);
    // System.out.println(c.getFilesDir().getPath());
    try{
      index = new ANNIndex(512, path, IndexType.EUCLIDEAN);
    } catch(IOException e) {
      result.error("IOException", "Could not load embeddings", null);
    }
  }

  private List<Integer> getSimilarIndices() {
    float[] itemVector = index.getItemVector(1500);
    List<Integer> retrievedResults = index.getNearest(itemVector, 10);
    return retrievedResults;
  }

  private List<Integer> getSimilarToVector(float[] itemVector) {
    List<Integer> retrievedResults = index.getNearest(itemVector, 10);
    return retrievedResults;
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    
    // loadEmbeddings();
    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
      new MethodCallHandler() {
          @Override
          public void onMethodCall(MethodCall call, Result result) {
              if (call.method.equals("findSimilar")) {
                // List<Integer> similarIndices = getSimilarIndices();
                List<Double> queryEmbedding = call.argument("queryEmbedding");
                float[] queryEmbeddingArray = new float[queryEmbedding.size()];
                int i = 0;
                for (Double f : queryEmbedding) {
                    // queryEmbeddingArray[i++] = (f != null ? f : Float.NaN);
                    queryEmbeddingArray[i++] = f.floatValue();
                }

                List<Integer> similarIndices = getSimilarToVector(queryEmbeddingArray);
                // Map response = new HashMap();
                // response.put("indices", similarIndices);
                result.success(similarIndices);
              } else if (call.method.equals("loadEmbeddings")) {
                String embeddingPath = call.argument("path");
                loadEmbeddings(embeddingPath, result);
                result.success("Embeddings Loaded Successfully");
              } else {
                result.notImplemented();
              }
          }
      });
  }
}

#ifndef FACE_RECOG_H
#define FACE_RECOG_H
#define _SILENCE_EXPERIMENTAL_FILESYSTEM_DEPRECATION_WARNING
#pragma once
#include <iostream>
#include<math.h>
#include <opencv2/opencv.hpp>
#include<opencv2/core.hpp>
#include<algorithm>
#include <experimental/filesystem>
#include<fstream>   //文本读写
#include<Windows.h> //控制台输出中文乱码
#include<opencv2/opencv.hpp>
#include<opencv2/highgui.hpp>
#include<opencv2/core.hpp>
#include <opencv2/highgui/highgui_c.h>
#include<opencv2/imgproc.hpp>
//#include<opencv2/xfeatures2d/nonfree.hpp>
#include <dlib/image_processing/frontal_face_detector.h>
#include <dlib/image_processing/render_face_detections.h>
#include <dlib/image_processing.h>
#include <dlib/gui_widgets.h>
#include <dlib/image_io.h>
#include <dlib/dnn.h>
#include <dlib/clustering.h>
#include <dlib/opencv.h>
#include<filesystem>

namespace fs = std::experimental::filesystem;
using namespace dlib;
using namespace cv;
using namespace std;

//定义一个网络
template <template <int, template<typename>class, int, typename> class block, int N, template<typename>class BN, typename SUBNET>
using residual = add_prev1<block<N, BN, 1, tag1<SUBNET>>>;
template <template <int, template<typename>class, int, typename> class block, int N, template<typename>class BN, typename SUBNET>
using residual_down = add_prev2<avg_pool<2, 2, 2, 2, skip1<tag2<block<N, BN, 2, tag1<SUBNET>>>>>>;
template <int N, template <typename> class BN, int stride, typename SUBNET>
using block = BN<con<N, 3, 3, 1, 1, relu<BN<con<N, 3, 3, stride, stride, SUBNET>>>>>;
template <int N, typename SUBNET> using ares = relu<residual<block, N, affine, SUBNET>>;
template <int N, typename SUBNET> using ares_down = relu<residual_down<block, N, affine, SUBNET>>;
template <typename SUBNET> using alevel0 = ares_down<256, SUBNET>;
template <typename SUBNET> using alevel1 = ares<256, ares<256, ares_down<256, SUBNET>>>;
template <typename SUBNET> using alevel2 = ares<128, ares<128, ares_down<128, SUBNET>>>;
template <typename SUBNET> using alevel3 = ares<64, ares<64, ares<64, ares_down<64, SUBNET>>>>;
template <typename SUBNET> using alevel4 = ares<32, ares<32, ares<32, SUBNET>>>;
using anet_type = loss_metric<fc_no_bias<128, avg_pool_everything<
    alevel0<
    alevel1<
    alevel2<
    alevel3<
    alevel4<
    max_pool<3, 3, 2, 2, relu<affine<con<32, 7, 7, 2, 2,
    input_rgb_image_sized<150>
    >>>>>>>>>>>>;
class FaceRcog{
public:
    //人脸信息结构体
    struct person
    {
        //人脸编码
        string name = "None";
        //人脸图像
        cv::Mat face;
    };

    //截取一段视频中第n秒图像
    cv::Mat photo_load(const string src, int sec);
    //初始化人脸识别器
    void Init_detctor();
    //初始化人脸探测器
    void Init_shape();
    //初始化网络
    void Init_net();
    //提取人脸68个关键点
    std::vector<dlib::full_object_detection> getshapes(cv::Mat& frame, std::vector<dlib::rectangle>& dets);
    //计算单个人脸的特征值
    dlib::matrix<float, 0, 1> get_128D(dlib::full_object_detection& shape, cv::Mat& frame);
    //计算两张人脸的相似度
    double GetSIM(const matrix<float, 0, 1> src_face128D, const matrix<float, 0, 1> com_face_128D);
    //提取视频某一秒的所有人脸的特征向量
    std::vector<dlib::matrix<float, 0, 1>> VideoTo128D(const string srcPath, int sec, std::vector<dlib::rectangle> dets);
    std::vector<matrix<float, 0, 1>> FindAllFile(std::string path, std::vector<std::string>& name, std::vector<cv::Mat>& face_base);
    std::vector<FaceRcog::person> getface_ID(const string video_path, int sec, string face_path);
};

#endif // FACE_RECOG_H

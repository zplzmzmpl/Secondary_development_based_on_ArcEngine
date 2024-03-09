#include"face_recog.h"
#include<QDebug>
#include<qstring.h>
dlib::frontal_face_detector detector;//dlib的人脸识别器
dlib::shape_predictor sp;//人脸形状探测器
anet_type net;//特征提取网络


//截取一段视频中第n秒图像
cv::Mat FaceRcog::photo_load(const string src, int sec)
{
    /*
    截取一段视频中第n秒图像
    src-视频绝对链接，sec-要截取第几秒的图像
    */
    VideoCapture capture;
    capture.open(src);
    //检查是否打开成功
    if (!capture.isOpened())
        qDebug() << "fail to open !" << endl;
    //获取整个帧数
    long totalFrameNumber = capture.get(CAP_PROP_FRAME_COUNT);//获取视频的帧数
    qDebug() << "total fps in this video:" << totalFrameNumber << endl;
    //从设置帧开始
    long frameToStart = 1;
    capture.set(CAP_PROP_POS_FRAMES, frameToStart);
    qDebug() << "从第" << frameToStart << "帧开始读" << endl;
    int frameTostop = totalFrameNumber;
    if (frameTostop < frameToStart)
    {
       qDebug() << "error" << endl;

    }
    double rate = capture.get(CAP_PROP_FPS);//获取视频的帧率FPS
    qDebug() << "帧率为：" << rate << endl;
    //face为返回值
    Mat face;
    while (frameToStart < frameTostop)
    {
        Mat rface;
        frameToStart += 1;
        int fps = round(rate);
        capture >> rface;
        //获取所需求秒数的人脸
        if (frameToStart == sec * fps)
        {
            face = rface;
            break;
        }
    }
    //返回人脸
    return face;
}

//初始化人脸识别器
void FaceRcog::Init_detctor()
{
    detector = dlib::get_frontal_face_detector();
}

//初始化人脸探测器
void FaceRcog::Init_shape()
{
    dlib::deserialize("E:\\Qt\\qt5152\\myfile\\Buffer\\shape_predictor_68_face_landmarks.dat") >> sp;
}

//初始化网络
void FaceRcog::Init_net()
{
    dlib::deserialize("E:\\Qt\\qt5152\\myfile\\Buffer\\dlib_face_recognition_resnet_model_v1.dat") >> net;
}

//提取人脸68个关键点
std::vector<full_object_detection> FaceRcog::getshapes(Mat &frame, std::vector<dlib::rectangle> &dets)
{
    /*
    输入参数：frame-人脸图像
    输出参数：dets-视频截图中人脸的位置数据
    返回值：shapes-人脸形状的数据数组
    */
    cv::Mat dst;
    //将frame变为变为灰度，存储在dst中
    cv::cvtColor(frame, dst, cv::COLOR_RGB2GRAY);
    //将Mat转化为dlib的matrix
    dlib::array2d<dlib::bgr_pixel> dimg;
    dlib::assign_image(dimg, dlib::cv_image<uchar>(dst));
    //至此frame转变为了 dimg
    //获取一系列人脸所在区域
    dets = detector(dimg);
    std::vector<dlib::full_object_detection> shapes;
    int face_number = dets.size();//检测到的人脸数，每个区域只有一个人脸
    qDebug() <<"numbers of people:"<< face_number << endl;
    for (int i = 0; i < face_number; i++)
    {
        //获取指定一个区域的人脸形状
        dlib::full_object_detection shape = sp(dimg, dets[i]);
        shapes.push_back(shape);
    }
    return shapes;
}

//计算单个人脸的特征向量
dlib::matrix<float, 0, 1> FaceRcog::get_128D(full_object_detection &shape, Mat &frame)
{
    /*
    输入参数：shape-单个人脸形状，frame-人脸图像
    返回值：face_descriptors[0]-单个人脸的128维特征向量
    */

    //计算该人脸的特征值
    std::vector<dlib::matrix<dlib::rgb_pixel>> faces;//定义映射后的人脸
    dlib::matrix<dlib::rgb_pixel> face_chip;
    dlib::matrix<dlib::rgb_pixel> img;
    //frame变换类型
    dlib::assign_image(img, dlib::cv_image<dlib::rgb_pixel>(frame));
    //将人脸坐标其映射到标准人脸上去
    dlib::extract_image_chip(img, dlib::get_face_chip_details(shape, 150, 0.25), face_chip);
    faces.push_back(face_chip);
    std::vector<dlib::matrix<float, 0, 1>> face_descriptors = net(faces);//得到128D特征数据
    return face_descriptors[0];
}

//计算两张人脸的相似度
double FaceRcog::GetSIM(const matrix<float, 0, 1> src_face128D, const matrix<float, 0, 1> com_face_128D)
{
    /*
    输入参数：src_face128D-要识别的人脸特征向量，com_face128D-人脸库人脸特征向量
    返回值：sim-两张人脸的相似度
    */
    double sim = (double)length(src_face128D - com_face_128D);
    return sim;
}

//提取视频某一秒的所有人脸的特征向量
std::vector<dlib::matrix<float, 0, 1> > FaceRcog::VideoTo128D(const string srcPath, int sec, std::vector<dlib::rectangle> dets)
{
    /*
    输入参数：srcPath-视频地址，sec-视频第n秒
    输出参数：dets-截图中人脸位置信息
    返回值：video_128D-截图中全部人脸特征向量
    */
    std::vector<matrix<float, 0, 1>> video_128D;//人脸特征向量数组
    //得到视频截图
    Mat src = photo_load(srcPath, sec);

    //初始化
    Init_detctor();
    Init_shape();
    Init_net();

    //获取68个人脸关键点
    std::vector<dlib::full_object_detection> shapes;//存储人脸形状的容器
    shapes = getshapes(src, dets);

    //获取128维特征向量
    for (auto shape : shapes)
    {
        matrix<float, 0, 1> data;
        data = get_128D(shape, src);
        video_128D.push_back(data);
    }
    //输出特征向量
    //for (int j = 0; j < video_128D.size(); j++)
    //{
    //	qDebug() << "特征向量： face_" <<j<<" :"<< trans(video_128D.at(j)) << endl;
    //}
    return video_128D;
}


//提取人脸库中人脸的特征向量
std::vector<matrix<float, 0, 1> > FaceRcog::FindAllFile(string path, std::vector<string> &name, std::vector<Mat> &face_base)
{
    /*
    输入参数：path-人脸库文件夹路径
    输出参数：name-人脸库人脸文件名（编码），face_base-人脸库人脸图像
    返回值：facedata_128D-人脸库全部人脸特征向量
    */

    std::vector<string> fin_path;//文件夹下所有文件的路径
    std::vector<matrix<float, 0, 1>> facedata_128D;//人脸库全部人脸特征向量
    //初始化
    Init_detctor();
    Init_shape();
    Init_net();

    //获取文件名（人脸编码）
    for (auto& v : fs::directory_iterator(path))
    {
        if (fs::is_regular_file(v.path()))
        {
            std::string tpath;
            tpath = v.path().string();
            fin_path.push_back(tpath);
            std::string na = v.path().filename().string();
            name.push_back(na.substr(0,na.size()-4));

        }
    }
    //计算人脸特征向量
    for (int i = 0; i < fin_path.size(); i++)
    {
        cv::Mat com = imread(fin_path.at(i));
        face_base.push_back(com);
        std::vector<dlib::rectangle> dets;//存储人脸区域的容器，即人脸在frame上的位置坐标
        std::vector<dlib::full_object_detection> shapes;//存储人脸形状的容器
        shapes = getshapes(com, dets);//得到人脸关键点
        matrix<float, 0, 1> data;//存储单个人脸特征向量
        data = get_128D(shapes.at(0), com);//得到人脸特征向量
        facedata_128D.push_back(data);
        qDebug() << QString::fromStdString(fin_path.at(i)) << endl;
    }
    //显示特征向量
    //for (int j = 0; j < facedata_128D.size(); j++)
    //{
    //	qDebug() << "特征向量： face_" << j << " :" << trans(facedata_128D.at(j)) << endl;
    //}
    return facedata_128D;
}

//为要识别的人脸赋予编号
std::vector<FaceRcog::person> FaceRcog::getface_ID(const string video_path, int sec, string face_path)
{
    /*
    输入参数：video_path-视频文件地址，face_path-人脸库文件夹地址
    返回值：persondata-人脸信息数组
    */

    std::vector<matrix<float, 0, 1>> video;
    std::vector<dlib::rectangle> dets;//存储人脸区域的容器，即人脸在frame上的位置坐标
    video = VideoTo128D(video_path, sec, dets);
    std::vector<string> name;
    std::vector<cv::Mat> face_base;
    std::vector<matrix<float, 0, 1>> face_data = FindAllFile(face_path, name, face_base);
    std::vector<FaceRcog::person> persondata;
    for (int i = 0; i < video.size(); i++)
    {
        for (int j = 0; j < face_data.size(); j++)
        {
            double sim = GetSIM(video.at(i), face_data.at(j));
            if (sim <= 0.4)//设置距离阈值为0.4，小于0.4则认为是同一人
            {
                FaceRcog::person pdata;
                pdata.name = name.at(j);
                pdata.face = face_base.at(j);
                persondata.push_back(pdata);
            }
        }
    }
    //显示识别到的人脸
    for (int i = 0; i < persondata.size(); i++)
    {
        qDebug() << QString::fromStdString(persondata.at(i).name) << endl;
        dlib::cv_image<rgb_pixel> img(persondata.at(i).face);
        image_window win;
        win.set_image(img);
        system("pause");
    }
    return persondata;
}

//int main()
//{
//    std::vector<person> persond;
//    persond = getface_ID("C:\\Users\\86153\\Downloads\\VCG42N1273904028.mp4", 2, "C:\\Users\\86153\\Desktop\\face");
//    system("pause");
//    waitKey(0);

//    return 0;
//}

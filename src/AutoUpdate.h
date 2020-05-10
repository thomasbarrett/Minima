#ifndef AUTO_UPDATE_H
#define AUTO_UPDATE_H

#include <curl/curl.h>
#include <iostream>
#include <rapidjson/document.h>
#include <rapidjson/stringbuffer.h>
#include <future>
#include <fstream>

class AutoUpdate {
private:
    std::string metadata_url_ = "https://s3.amazonaws.com/com.thomasbarrett.minima/metadata.json";
    std::string metadata_path_;

    rapidjson::Document local_metadata_;
    rapidjson::Document remote_metadata_;

    static size_t write_callback(void *contents, size_t size, size_t nmemb, void *str) {
        ((std::string*)str)->append((char*)contents, size * nmemb);
        return size * nmemb;
    }

public:

    AutoUpdate(const std::string &metadata_path) {     
        metadata_path_ = metadata_path;
        std::ifstream metadata_stream(metadata_path_);
        std::string metadata_string((std::istreambuf_iterator<char>(metadata_stream)), std::istreambuf_iterator<char>());
        local_metadata_.Parse(metadata_string.c_str());

        std::string buffer;
        CURL *curl = curl_easy_init();
        if(curl) {
            curl_easy_setopt(curl, CURLOPT_URL, metadata_url_.c_str());
            curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_callback);
            curl_easy_setopt(curl, CURLOPT_WRITEDATA, &buffer);
            curl_easy_perform(curl);
            curl_easy_cleanup(curl);

            remote_metadata_.Parse(buffer.c_str());
        }
        
    }

    std::string latestVersion() {
        if (remote_metadata_.HasMember("currentVersion") && remote_metadata_["currentVersion"].IsString()) {
            return remote_metadata_["currentVersion"].GetString();
        } else return "";
    }

    std::string currentVersion() {
        if (local_metadata_.HasMember("currentVersion") && local_metadata_["currentVersion"].IsString()) {
            return local_metadata_["currentVersion"].GetString();
        } else return "";
    }
};

#endif /* AUTO_UPDATE_H */
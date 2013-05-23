package main

import (
    "files"
    "flag"
    "fmt"
    "fsnotify"
    "log"
    "net/http"
    "os/exec"
    "path/filepath"
    "runtime"
    "time"
)

var (
    openPort = flag.String("p", "8080", "http listen port")
    webRoot  = flag.String("r", "./", "web site root")
    watchDir = flag.String("d", "wiki", "default watch wiki directory")
)

func init() {
    runtime.GOMAXPROCS(runtime.NumCPU())
}

// Watch 监听该项目，源码有改动会重新编译运行
func Watcher(root string) error {
    watcher, err := fsnotify.NewWatcher()
    eventNum := make(chan int)
    if err != nil {
        return err
    }
    go func() {
        for {
            i := 0
        GetEvent:
            for {
                select {
                case event := <-watcher.Event:
                    log.Println(event.Name)
                    i++
                    // 修改可能会有多次modify事件
                case <-time.After(time.Second * 2):
                    break GetEvent
                }
            }
            if i > 0 {
                eventNum <- i
            }
        }
    }()

    //监控子目录
    dirWatch(watcher, root)

    //监听enentNum执行相应的操作
    go func() {
        for {
            var err error
            select {
            case <-eventNum:
                cmd := exec.Command("make")
                if err = cmd.Start(); err != nil {
                    log.Println("Run Error", err)
                }
                log.Println("finish make")
            }
        }
    }()
    return nil
}

// dirWatch 使用fsnotify，监听src目录以及子目录
func dirWatch(watcher *fsnotify.Watcher, dir string) {
    log.Println("watch: ", dir)
    watcher.Watch(dir)
    for _, subDir := range files.ScanDir(dir) {
        childDir := filepath.Join(dir, subDir)
        if files.IsDir(childDir) {
            dirWatch(watcher, childDir)
        }
    }
}

func main() {
    flag.Parse()
    Watcher(*watchDir)
    fmt.Println("http server open port : ", *openPort)
    fmt.Println("http server web root : ", *webRoot)
    http.Handle("/", http.FileServer(http.Dir(*webRoot)))
    //port := fmt.Sprintf(":",*openPort)
    http.ListenAndServe(":"+*openPort, nil)
}

<?php

// Пример подключения к SFTP через Laravel
// Добавьте в composer.json: "phpseclib/phpseclib": "~3.0"

use phpseclib3\Net\SFTP;
use phpseclib3\Crypt\PublicKeyLoader;

class SFTPService
{
    private $sftp;
    private $host = 'localhost';
    private $port = 2222;
    private $username = 'sftpuser';
    private $privateKeyPath;

    public function __construct()
    {
        // Путь к приватному ключу
        $this->privateKeyPath = storage_path('keys/id_rsa');
    }

    /**
     * Подключение к SFTP серверу через приватный ключ
     */
    public function connect()
    {
        try {
            $this->sftp = new SFTP($this->host, $this->port);
            
            // Загрузка приватного ключа
            $privateKey = PublicKeyLoader::load(file_get_contents($this->privateKeyPath));
            
            // Подключение
            if (!$this->sftp->login($this->username, $privateKey)) {
                throw new Exception('SFTP Login Failed');
            }
            
            return true;
        } catch (Exception $e) {
            throw new Exception('SFTP Connection Failed: ' . $e->getMessage());
        }
    }

    /**
     * Загрузка файла на SFTP сервер
     */
    public function uploadFile($localPath, $remotePath)
    {
        if (!$this->sftp) {
            $this->connect();
        }

        if ($this->sftp->put($remotePath, $localPath, SFTP::SOURCE_LOCAL_FILE)) {
            return true;
        }
        
        throw new Exception('File upload failed');
    }

    /**
     * Скачивание файла с SFTP сервера
     */
    public function downloadFile($remotePath, $localPath)
    {
        if (!$this->sftp) {
            $this->connect();
        }

        if ($this->sftp->get($remotePath, $localPath)) {
            return true;
        }
        
        throw new Exception('File download failed');
    }

    /**
     * Получение списка файлов
     */
    public function listFiles($directory = '/upload')
    {
        if (!$this->sftp) {
            $this->connect();
        }

        return $this->sftp->nlist($directory);
    }

    /**
     * Удаление файла
     */
    public function deleteFile($remotePath)
    {
        if (!$this->sftp) {
            $this->connect();
        }

        return $this->sftp->delete($remotePath);
    }

    /**
     * Создание директории
     */
    public function createDirectory($path)
    {
        if (!$this->sftp) {
            $this->connect();
        }

        return $this->sftp->mkdir($path);
    }

    /**
     * Закрытие соединения
     */
    public function disconnect()
    {
        if ($this->sftp) {
            $this->sftp->disconnect();
        }
    }
}

// Пример использования в контроллере
class SFTPController extends Controller
{
    protected $sftpService;

    public function __construct(SFTPService $sftpService)
    {
        $this->sftpService = $sftpService;
    }

    public function uploadFile(Request $request)
    {
        try {
            $file = $request->file('upload');
            
            if ($file) {
                $localPath = $file->getPathname();
                $remotePath = '/upload/' . $file->getClientOriginalName();
                
                $this->sftpService->uploadFile($localPath, $remotePath);
                
                return response()->json(['success' => true, 'message' => 'File uploaded successfully']);
            }
            
            return response()->json(['success' => false, 'message' => 'No file provided']);
            
        } catch (Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()]);
        }
    }

    public function listFiles()
    {
        try {
            $files = $this->sftpService->listFiles();
            return response()->json(['success' => true, 'files' => $files]);
        } catch (Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()]);
        }
    }
}

// Пример использования в artisan команде
class TestSFTPCommand extends Command
{
    protected $signature = 'sftp:test';
    protected $description = 'Тест SFTP подключения';

    public function handle()
    {
        $sftpService = new SFTPService();
        
        try {
            $this->info('Подключение к SFTP серверу...');
            $sftpService->connect();
            $this->info('✓ Подключение успешно!');
            
            $this->info('Получение списка файлов...');
            $files = $sftpService->listFiles();
            $this->info('Файлы: ' . implode(', ', $files));
            
            // Создание тестового файла
            $testFile = storage_path('test.txt');
            file_put_contents($testFile, 'Тестовый файл для SFTP');
            
            $this->info('Загрузка тестового файла...');
            $sftpService->uploadFile($testFile, '/upload/test.txt');
            $this->info('✓ Файл загружен успешно!');
            
            // Удаление локального тестового файла
            unlink($testFile);
            
            $sftpService->disconnect();
            $this->info('✓ Тест завершен успешно!');
            
        } catch (Exception $e) {
            $this->error('Ошибка: ' . $e->getMessage());
        }
    }
}

// Добавьте в routes/web.php или routes/api.php:
/*
Route::post('/sftp/upload', [SFTPController::class, 'uploadFile']);
Route::get('/sftp/files', [SFTPController::class, 'listFiles']);
*/

// Добавьте в app/Console/Kernel.php в массив $commands:
/*
\App\Console\Commands\TestSFTPCommand::class,
*/
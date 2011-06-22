/* written by @kazuho */
#include <assert.h>
#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/select.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

static double now(void)
{
  struct timeval tv;
  gettimeofday(&tv, NULL);
  return tv.tv_sec + (double)tv.tv_usec / 1000000;
}

static int got_usr1 = 0;

static void on_sigusr1(int _unused)
{
  got_usr1 = 1;
}

int main(int argc, char** argv)
{
  sigset_t blockset, unblockset;
  pid_t child_pid;
  int ret;

  /* setup sigsets */
  sigemptyset(&blockset);
  sigaddset(&blockset, SIGUSR1);
  sigfillset(&unblockset);
  sigdelset(&unblockset, SIGUSR1);

  /* start blocking the signal */
  sigprocmask(SIG_BLOCK, &blockset, NULL);

  /* set signal handler */
  signal(SIGUSR1, on_sigusr1);

  /* create child process that sendns SIGUSR1 every 5 millisecs */
  child_pid = fork();
  switch (child_pid) {
  case -1:
    perror("fork failed");
    exit(1);
  case 0: /* child process */
    kill(getppid(), SIGUSR1);
    exit(0);
    /* unreachable */
  default:
    break;
  }

  while (wait(NULL) != child_pid)
    ;

  {
    double start_at = now(), elapsed;
    if (! got_usr1) {
      const static struct timespec ts = { 1, 0 };
      ret = pselect(1, NULL, NULL, NULL, &ts, &unblockset);
      printf("ret (should be -1): %d\n", ret);
      printf("errno (should be EINTR(%d)): %d\n", EINTR, errno);
    }
    assert(got_usr1);
    elapsed = now() - start_at;
    assert(elapsed < 0.05);
    got_usr1 = 0;
  }

  return 0;
}

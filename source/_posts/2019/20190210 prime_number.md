---
title: 测试驱动开发的一个示例代码——求质因数
categories:  
- 备忘
- 技术
tags: 
- java
---

```
package test;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class TestMain {


    public static int[] getPrimeFactor(int input) {
        List<Integer> result = new ArrayList<>();

        switch (input) {
            case 0 | 1:
                result.add(input);
                break;
            default:
                result = doSth(input);
        }

        return Arrays.stream(result.toArray(new Integer[result.size()]))
                .mapToInt(Integer::intValue)
                .toArray();
    }

    private static List<Integer> doSth(int input) {
        List<Integer> result = new ArrayList<>();

        for (int i = 2; i <= input; i++) {
            while (input % i == 0) {
                result.add(i);
                input /= i;
            }
        }
        return result;
    }
}

```


```
package test;

import org.junit.Assert;
import org.junit.Test;

public class TestTest {

    @Test
    public void shouldReturn0Given0(){
        int[] expect = {0};
        Assert.assertArrayEquals(TestMain.getPrimeFactor(0), expect);
    }
    @Test
    public void shouldReturn1Given1(){
        int[] expect = {1};
        Assert.assertArrayEquals(TestMain.getPrimeFactor(1), expect);
    }
    @Test
    public void shouldReturn2Given2(){
        int[] expect = {2};
        Assert.assertArrayEquals(TestMain.getPrimeFactor(2), expect);
    }
    @Test
    public void shouldReturn3Given3(){
        int[] expect = {3};
        Assert.assertArrayEquals(TestMain.getPrimeFactor(3), expect);
    }
    @Test
    public void shouldReturn2_2Given4(){
        int[] expect = {2,2};
        Assert.assertArrayEquals(TestMain.getPrimeFactor(4), expect);
    }
    @Test
    public void shouldReturn5Given5(){
        int[] expect = {5};
        Assert.assertArrayEquals(TestMain.getPrimeFactor(5), expect);
    }
    @Test
    public void shouldReturn2_3Given6(){
        int[] expect = {2,3};
        Assert.assertArrayEquals(TestMain.getPrimeFactor(6), expect);
    }
    @Test
    public void shouldReturn2_2_2Given8(){
        int[] expect = {2,2,2};
        Assert.assertArrayEquals(TestMain.getPrimeFactor(8), expect);
    }
    @Test
    public void shouldReturn3_3Given9(){
        int[] expect = {3,3};
        Assert.assertArrayEquals(TestMain.getPrimeFactor(9), expect);
    }
    @Test
    public void shouldReturn2_5Given10(){
        int[] expect = {2,5};
        Assert.assertArrayEquals(TestMain.getPrimeFactor(10), expect);
    }
    @Test
    public void shouldReturn3_5Given15(){
        int[] expect = {3,5};
        Assert.assertArrayEquals(TestMain.getPrimeFactor(15), expect);
    }
    @Test
    public void shouldReturn2_2_5_5Given100(){
        int[] expect = {2,2,5,5};
        Assert.assertArrayEquals(TestMain.getPrimeFactor(100), expect);
    }

    @Test
    public void shouldReturn13_13Given169(){
        int[] expect = {13,13};
        Assert.assertArrayEquals(TestMain.getPrimeFactor(169), expect);
    }
}
```

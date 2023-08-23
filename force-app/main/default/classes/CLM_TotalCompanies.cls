/**
* @description Wrapper class to hold json response of Total Companies Jagger API
* @createdDate Dec 9, 2021
*/
public class CLM_TotalCompanies {
    public Integer total;
    public Integer page;

    public CLM_TotalCompanies(Integer total, Integer page) {
        this.page = page;
        this.total = total;
    }
}